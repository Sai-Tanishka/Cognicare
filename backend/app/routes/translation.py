import json
import urllib.parse
import urllib.request
from typing import Optional
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

router = APIRouter(prefix="/api/translate", tags=["Translation"])

# In-memory translation cache: (text, target_lang) -> translated_text
_translation_cache: dict[tuple[str, str], str] = {}


class TranslateRequest(BaseModel):
    text: str
    target_lang: str
    source_lang: Optional[str] = "auto"


class TranslateResponse(BaseModel):
    translated_text: str
    target_lang: str
    source_lang: str
    cached: bool = False


@router.post("", response_model=TranslateResponse)
@router.post("/", response_model=TranslateResponse)
def translate(req: TranslateRequest):
    text = req.text.strip()
    target_lang = req.target_lang.strip()
    source_lang = (req.source_lang or "auto").strip()

    if not text:
        return TranslateResponse(
            translated_text="",
            target_lang=target_lang,
            source_lang=source_lang,
            cached=True,
        )

    # If target is same as source (e.g. en to en), return original
    if target_lang == source_lang or (target_lang == "en" and source_lang == "en"):
        return TranslateResponse(
            translated_text=text,
            target_lang=target_lang,
            source_lang=source_lang,
            cached=True,
        )

    cache_key = (text, target_lang)
    if cache_key in _translation_cache:
        return TranslateResponse(
            translated_text=_translation_cache[cache_key],
            target_lang=target_lang,
            source_lang=source_lang,
            cached=True,
        )

    try:
        encoded_query = urllib.parse.quote(text)
        url = (
            f"https://translate.googleapis.com/translate_a/single"
            f"?client=gtx&sl={source_lang}&tl={target_lang}&dt=t&q={encoded_query}"
        )

        req_obj = urllib.request.Request(
            url,
            headers={
                "User-Agent": (
                    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                    "AppleWebKit/537.36 (KHTML, like Gecko) "
                    "Chrome/124.0.0.0 Safari/537.36"
                ),
                "Accept": "*/*",
            },
        )

        with urllib.request.urlopen(req_obj, timeout=10) as response:
            raw_data = response.read().decode("utf-8")
            parsed = json.loads(raw_data)

            # Google Translate returns an array where [0] is a list of translated sentences
            if parsed and isinstance(parsed, list) and len(parsed) > 0 and isinstance(parsed[0], list):
                translated_sentences = []
                for sentence in parsed[0]:
                    if sentence and len(sentence) > 0 and sentence[0]:
                        translated_sentences.append(sentence[0])
                translated_result = "".join(translated_sentences)
            else:
                translated_result = text

            _translation_cache[cache_key] = translated_result

            return TranslateResponse(
                translated_text=translated_result,
                target_lang=target_lang,
                source_lang=source_lang,
                cached=False,
            )

    except Exception as e:
        # Fallback to original text gracefully so app never crashes
        return TranslateResponse(
            translated_text=text,
            target_lang=target_lang,
            source_lang=source_lang,
            cached=False,
        )


_tts_cache: dict[tuple[str, str], bytes] = {}


def _resolve_tts_lang(lang: str) -> str:
    code = lang.split("-")[0].lower()
    mapping = {
        "te": "te",  # Telugu
        "hi": "hi",  # Hindi
        "bn": "bn",  # Bengali
        "ta": "ta",  # Tamil
        "kn": "kn",  # Kannada
        "ml": "ml",  # Malayalam
        "mr": "mr",  # Marathi
        "gu": "gu",  # Gujarati
        "pa": "pa",  # Punjabi
        "ne": "ne",  # Nepali
        "ur": "ur",  # Urdu
        "en": "en",  # English
        "as": "bn",  # Assamese (Bengali voice reads Bengali-Assamese script naturally)
        "mni": "bn", # Manipuri
        "lus": "en", # Mizo (Latin script)
        "or": "hi",  # Odia fallback
    }
    return mapping.get(code, code)


def _split_into_chunks(text: str, max_len: int = 140) -> list[str]:
    import re
    sentences = re.findall(r"[^.!?।\n,]+[.!?।\n,]*", text)
    if not sentences:
        sentences = [text]

    chunks = []
    curr = ""
    for s in sentences:
        s_clean = s.strip()
        if not s_clean:
            continue
        if len(curr) + len(s_clean) + 1 <= max_len:
            curr = (curr + " " + s_clean).strip()
        else:
            if curr:
                chunks.append(curr)
            if len(s_clean) <= max_len:
                curr = s_clean
            else:
                words = s_clean.split(" ")
                sub = ""
                for w in words:
                    if len(sub) + len(w) + 1 <= max_len:
                        sub = (sub + " " + w).strip()
                    else:
                        if sub:
                            chunks.append(sub)
                        sub = w
                curr = sub
    if curr:
        chunks.append(curr)
    return chunks or [text]


@router.get("/tts")
def tts_stream(text: str, lang: str = "en"):
    import re
    from fastapi import Response

    clean_text = re.sub(r"[*_#`~]", "", text).strip()
    if not clean_text:
        return Response(content=b"", media_type="audio/mpeg")

    tts_lang = _resolve_tts_lang(lang)
    cache_key = (clean_text, tts_lang)
    if cache_key in _tts_cache:
        return Response(
            content=_tts_cache[cache_key],
            media_type="audio/mpeg",
            headers={
                "Cache-Control": "public, max-age=86400",
                "Accept-Ranges": "bytes",
            },
        )

    chunks = _split_into_chunks(clean_text, 140)
    full_audio = bytearray()

    headers = {
        "User-Agent": (
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
            "AppleWebKit/537.36 (KHTML, like Gecko) "
            "Chrome/124.0.0.0 Safari/537.36"
        ),
        "Accept": "*/*",
    }

    for chunk in chunks:
        encoded_query = urllib.parse.quote(chunk)
        url = (
            f"https://translate.google.com/translate_tts"
            f"?ie=UTF-8&q={encoded_query}&tl={tts_lang}&client=tw-ob"
        )
        try:
            req_obj = urllib.request.Request(url, headers=headers)
            with urllib.request.urlopen(req_obj, timeout=8) as response:
                full_audio.extend(response.read())
        except Exception:
            continue

    if not full_audio:
        raise HTTPException(status_code=502, detail="Failed to synthesize speech")

    result_bytes = bytes(full_audio)
    _tts_cache[cache_key] = result_bytes

    return Response(
        content=result_bytes,
        media_type="audio/mpeg",
        headers={
            "Cache-Control": "public, max-age=86400",
            "Accept-Ranges": "bytes",
        },
    )


class BatchTranslateRequest(BaseModel):
    texts: list[str]
    target_lang: str
    source_lang: Optional[str] = "auto"


class BatchTranslateResponse(BaseModel):
    translations: dict[str, str]
    target_lang: str


@router.post("/batch", response_model=BatchTranslateResponse)
def batch_translate(req: BatchTranslateRequest):
    results: dict[str, str] = {}
    target_lang = req.target_lang.strip()
    source_lang = (req.source_lang or "auto").strip()

    for text in req.texts:
        t = text.strip()
        if not t:
            results[text] = text
            continue
        if target_lang == source_lang or (target_lang == "en" and source_lang == "en"):
            results[text] = text
            continue

        cache_key = (t, target_lang)
        if cache_key in _translation_cache:
            results[text] = _translation_cache[cache_key]
            continue

        try:
            res = translate(TranslateRequest(text=t, target_lang=target_lang, source_lang=source_lang))
            results[text] = res.translated_text
        except Exception:
            results[text] = text

    return BatchTranslateResponse(translations=results, target_lang=target_lang)


class AssistantChatRequest(BaseModel):
    query: str
    patient_name: Optional[str] = "there"
    target_lang: Optional[str] = "en"
    activities_today: Optional[int] = 0
    goal_target: Optional[int] = 10
    caregiver_name: Optional[str] = "your caregiver"
    caregiver_rel: Optional[str] = "Primary caregiver"


class AssistantChatResponse(BaseModel):
    reply: str
    target_lang: str
    source: str


def _clean_wiki_title(raw: str) -> str:
    import re
    clean = re.sub(
        r"^(what is|what was|what are|what were|who is|who was|who were|where is|where was|tell me about|explain|define|can you tell me about|can you tell me what is|can you tell me who is)\s+",
        "",
        raw,
        flags=re.I,
    )
    clean = re.sub(r"^(the|a|an)\s+", "", clean, flags=re.I)
    return clean.strip(" ?.,!").strip()


def _answer_general_question(query: str, patient_name: str) -> tuple[str, str]:
    import re
    import random
    import datetime

    q = query.lower().strip()

    # 1. Jokes
    if any(k in q for k in ["joke", "funny", "laugh", "make me laugh"]):
        jokes = [
            "Why did the scarecrow win an award? Because he was outstanding in his field!",
            "Why do we tell actors to 'break a leg'? Because every play has a cast!",
            "What do you call a sleeping dinosaur? A dino-snore!",
            "Why don't scientists trust atoms? Because they make up everything!",
            "What did one wall say to the other wall? I will meet you at the corner!",
            "Why did the bicycle fall over? Because it was two-tired!",
        ]
        return random.choice(jokes), "joke"

    # 2. Stories
    if any(k in q for k in ["story", "tale", "fable"]):
        stories = [
            "Once, an old banyan tree sheltered countless birds through every storm. It taught the forest that having deep, calm roots brings peace and safety to everyone around.",
            "A traveler once asked an elder the secret to happiness. The elder smiled and said: 'Water your own garden with daily kindness, and colorful butterflies will always visit.'",
            "A little bird was timid about the morning winds, but its mother reminded it: 'The gentle wind is not there to push you, but to lift your wings so you discover how high you can soar.'",
        ]
        return random.choice(stories), "story"

    # 3. Quotes & Wisdom
    if any(k in q for k in ["quote", "inspire", "inspiration", "wisdom", "motto"]):
        quotes = [
            "Keep your face always toward the sunshine, and shadows will fall behind you.",
            "Every day is a fresh beginning. Take a deep breath, smile, and take one peaceful step forward.",
            "The secret of getting ahead is getting started, one gentle moment at a time.",
            "A warm heart and a curious mind make every single day brighter.",
        ]
        return random.choice(quotes), "quote"

    # 4. Live Date, Day, and Time
    if any(k in q for k in ["what time is it", "current time", "what is the time", "tell me the time", "what date", "today's date", "what is today's date", "what day is today", "what day is it", "which day is today", "which year", "today date"]):
        now = datetime.datetime.now()
        day_name = now.strftime("%A")
        date_str = now.strftime("%B %d, %Y")
        time_str = now.strftime("%I:%M %p")
        return f"Today is {day_name}, {date_str}. The current time is {time_str}.", "datetime"

    # 5. Arithmetic / Simple Math
    math_match = re.search(
        r"(?:what is|calculate|solve)?\s*(\d+(?:\.\d+)?)\s*([\+\-\*\/]|plus|minus|times|multiplied by|divided by)\s*(\d+(?:\.\d+)?)",
        q,
    )
    if math_match:
        try:
            n1 = float(math_match.group(1))
            op = math_match.group(2).strip()
            n2 = float(math_match.group(3))
            res = None
            if op in ["+", "plus"]:
                res = n1 + n2
            elif op in ["-", "minus"]:
                res = n1 - n2
            elif op in ["*", "times", "multiplied by"]:
                res = n1 * n2
            elif op in ["/", "divided by"] and n2 != 0:
                res = n1 / n2
            if res is not None:
                res_str = int(res) if res.is_integer() else f"{res:.2f}"
                n1_str = int(n1) if n1.is_integer() else str(n1)
                n2_str = int(n2) if n2.is_integer() else str(n2)
                return f"{n1_str} {op} {n2_str} equals {res_str}.", "math"
        except Exception:
            pass

    # 6. Memory Tips
    if any(k in q for k in ["memory", "remember", "forgetting", "brain exercise"]):
        return "To keep your memory sharp, practice daily brain games like Memory Match, stay physically active, drink water, and get 7 to 8 hours of peaceful sleep.", "health_tips"

    # 7. Sleep Tips
    if any(k in q for k in ["sleep", "insomnia", "sleeping", "rest", "tired"]):
        return "For restful sleep, keep a regular bedtime, avoid screens an hour before sleeping, enjoy a warm herbal tea, and practice slow, deep breathing.", "health_tips"

    # 8. Nutrition Tips
    if any(k in q for k in ["eat", "food", "diet", "nutrition", "healthy food", "breakfast", "dinner", "lunch"]):
        return "Nutritious foods that help protect your brain include fresh green vegetables, berries, walnuts, whole grains, and drinking clean water throughout the day.", "health_tips"

    # 9. Hydration
    if any(k in q for k in ["drink water", "hydration", "dehydration", "how much water"]):
        return "Drinking 6 to 8 glasses of water every day keeps your body refreshed, your mind alert, and supports healthy energy levels.", "health_tips"

    # 10. Identity
    if any(k in q for k in ["who are you", "what are you", "your name", "what is cognicare"]):
        return f"Hello {patient_name}! I am CogniCare, your personalized companion and cognitive assistant. I am here to help you exercise your mind, keep track of reminders, and support your daily wellness.", "identity"

    # 11. Wikipedia Search & Summary (Fast, accurate encyclopedic facts)
    try:
        clean = _clean_wiki_title(query)
        if clean:
            headers = {"User-Agent": "CogniCareCompanion/1.0 (contact@cognicare.org)"}
            candidates = [clean, clean.title()]
            try:
                op_url = f"https://en.wikipedia.org/w/api.php?action=opensearch&search={urllib.parse.quote(clean)}&limit=3&namespace=0&format=json"
                req = urllib.request.Request(op_url, headers=headers)
                with urllib.request.urlopen(req, timeout=4) as op_res:
                    op_data = json.loads(op_res.read().decode("utf-8"))
                    if len(op_data) > 1 and op_data[1]:
                        candidates = op_data[1] + candidates
            except Exception:
                pass

            for cand in candidates:
                try:
                    title = cand.replace(" ", "_")
                    sum_url = f"https://en.wikipedia.org/api/rest_v1/page/summary/{urllib.parse.quote(title)}"
                    req = urllib.request.Request(sum_url, headers=headers)
                    with urllib.request.urlopen(req, timeout=4) as s_res:
                        s_data = json.loads(s_res.read().decode("utf-8"))
                        extract = s_data.get("extract", "")
                        if extract and len(extract) > 20 and not extract.startswith("May refer to"):
                            sentences = re.split(r"(?<=[.!?])\s+", extract)
                            summary = " ".join(sentences[:2]).strip()
                            if summary:
                                return summary, "wikipedia"
                except Exception:
                    continue
    except Exception:
        pass

    # 12. Free Conversational AI fallback (Pollinations with short timeout)
    try:
        ai_prompt = (
            f"You are CogniCare AI, a warm, kind virtual companion for {patient_name}. "
            f"Answer the following question clearly and helpfully in 1 to 2 short sentences without markdown, bullets, or emojis: {query}"
        )
        encoded = urllib.parse.quote(ai_prompt)
        ai_url = f"https://text.pollinations.ai/{encoded}"
        req_obj = urllib.request.Request(ai_url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req_obj, timeout=5) as res:
            ans = res.read().decode("utf-8").strip()
            ans = re.sub(r"[*_#`~]", "", ans).strip()
            if ans and not ans.startswith("Im sorry, but I cant") and not ans.startswith("I am unable to"):
                return ans, "pollinations"
    except Exception:
        pass

    # 13. Smart topic-based companion fallback
    clean_topic = re.sub(r"^(what is|who is|where is|tell me about|explain)\s+", "", query, flags=re.I).strip(" ?.")
    if clean_topic:
        return f"Regarding {clean_topic}, that is a wonderful subject! Learning and asking questions every day helps keep your mind bright and active. What specific part of it would you like to explore next?", "fallback"

    return f"I heard your question, {patient_name}. Staying curious and engaged is wonderful for cognitive wellness. What else would you like to talk about today?", "fallback"


@router.post("/assistant-chat", response_model=AssistantChatResponse)
def assistant_chat(req: AssistantChatRequest):
    raw_query = req.query.strip()
    q = raw_query.lower()
    patient_name = (req.patient_name or "there").strip()
    target_lang = (req.target_lang or "en").strip()
    activities_today = req.activities_today or 0
    goal_target = req.goal_target or 10
    caregiver_name = req.caregiver_name or "your caregiver"
    caregiver_rel = req.caregiver_rel or "Primary caregiver"

    english_reply = ""
    source = "cognicare"

    # 1. Check core CogniCare intents first for instant, accurate patient data
    if any(k in q for k in ["progress", "doing today", "how am i", "my score", "daily goal", "status"]):
        if activities_today == 0:
            english_reply = f"Hello {patient_name}! You have not started your activities yet today. Your daily goal is {goal_target} activities. Let us play a quick memory game to get started!"
        elif activities_today >= goal_target:
            english_reply = f"Incredible work, {patient_name}! You have completed all {activities_today} of your {goal_target} daily activities today. You have achieved your full daily goal!"
        else:
            remaining = goal_target - activities_today
            english_reply = f"You are doing wonderful, {patient_name}! Today you have completed {activities_today} of your {goal_target} activities. Just {remaining} more to complete today's goal!"

    elif any(k in q for k in ["reminder", "medicine", "medication", "pill", "tablet", "water", "hydration"]):
        english_reply = "Here are your reminders for today: Take Donepezil 10mg with water after breakfast, practice your daily Memory Match exercise, drink water this afternoon, and take your evening vitamins."

    elif any(k in q for k in ["game", "activity", "play", "exercise", "memory match", "pattern recall", "odd one out", "number sequence"]):
        english_reply = "I recommend playing Memory Match or Pattern Recall today! They are enjoyable exercises that train visual recall and attention."

    elif any(k in q for k in ["caregiver", "doctor", "ramu", "who is taking care", "contact"]):
        english_reply = f"Your connected {caregiver_rel} is {caregiver_name}. They have direct access to your daily cognitive updates and are always there to support you."

    elif any(k in q for k in ["anxious", "sad", "worried", "lonely", "scared", "stress", "stressed", "bad"]):
        english_reply = f"I hear you, {patient_name}, and I am right here with you. Take a slow, deep breath in, and gently exhale. You are safe, you are cared for, and taking things one step at a time is all you need to do."

    elif any(k in q for k in ["happy", "great", "wonderful", "fine", "cheerful"]):
        english_reply = f"I am so glad to hear that, {patient_name}! A positive mindset makes every day brighter. Keep that wonderful energy going!"

    elif any(q.startswith(g) for g in ["hi", "hello", "hey", "good morning", "good afternoon", "good evening"]):
        english_reply = f"Hello {patient_name}! It is wonderful to hear from you. I can answer any questions you have, check your daily progress, or help you with your reminders and games."

    elif any(k in q for k in ["thank", "thanks"]):
        english_reply = f"You are most welcome, {patient_name}! I am always here whenever you want to talk or ask anything."

    # 2. General Knowledge / Broad Q&A / Companionship Engine
    if not english_reply:
        reply_text, reply_source = _answer_general_question(raw_query, patient_name)
        english_reply = reply_text
        source = reply_source

    # 3. Translate into target language if not English
    final_reply = english_reply
    if target_lang != "en":
        try:
            tr_res = translate(TranslateRequest(text=english_reply, target_lang=target_lang, source_lang="en"))
            final_reply = tr_res.translated_text
        except Exception:
            final_reply = english_reply

    return AssistantChatResponse(
        reply=final_reply,
        target_lang=target_lang,
        source=source,
    )



