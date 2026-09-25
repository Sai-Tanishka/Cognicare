"""
Seed script to initialize daily task tables and populate initial 15 Daily SPT templates.
"""
from app.database.connection import SessionLocal, engine, Base
from app.models.people import Patient
from app.models.daily_task import DailyTaskTemplate, DailyTask

SAMPLE_TEMPLATES = [
    {
        "code": "SPT-ARM-EXERCISE",
        "title": "Seated Arm Exercise",
        "description": "Gently raise and lower both arms while seated comfortably.",
        "instructions": (
            "Sit upright in a sturdy chair with feet flat on the floor. "
            "Slowly raise both arms forward to shoulder height. "
            "Hold for 2 seconds, then gently lower them. "
            "Repeat 5 times at a calm, relaxed pace."
        ),
        "visual_steps": [
            {"step": 1, "title": "Sit upright", "detail": "Sit comfortably in a sturdy chair with your back straight.", "icon": "chair"},
            {"step": 2, "title": "Raise arms", "detail": "Slowly raise both arms forward to shoulder height.", "icon": "accessibility_new"},
            {"step": 3, "title": "Lower arms", "detail": "Gently lower your arms back down and pause.", "icon": "self_improvement"},
            {"step": 4, "title": "Repeat 5 times", "detail": "Do this 5 times gently without rushing.", "icon": "replay"},
        ],
        "task_category": "PHYSICAL_ACTIVITY",
        "difficulty": "EASY",
        "submission_type": "VIDEO",
        "estimated_duration": "5 mins",
        "order_index": 1,
    },
    {
        "code": "SPT-BREATH-STRETCH",
        "title": "Gentle Breathing & Neck Stretch",
        "description": "Relax your shoulders, turn your head gently, and take deep breaths.",
        "instructions": (
            "Sit tall with your shoulders relaxed. "
            "Gently turn your head to the left, hold for 3 seconds, then return to center. "
            "Turn to the right, hold for 3 seconds. "
            "Take 3 slow, deep breaths in through your nose and out through your mouth."
        ),
        "visual_steps": [
            {"step": 1, "title": "Relax shoulders", "detail": "Sit with comfortable posture and let your shoulders drop.", "icon": "spa"},
            {"step": 2, "title": "Turn left", "detail": "Gently turn your head to the left for 3 seconds.", "icon": "arrow_back"},
            {"step": 3, "title": "Turn right", "detail": "Gently turn your head to the right for 3 seconds.", "icon": "arrow_forward"},
            {"step": 4, "title": "Deep breaths", "detail": "Take 3 deep, soothing breaths in and out.", "icon": "air"},
        ],
        "task_category": "PHYSICAL_ACTIVITY",
        "difficulty": "EASY",
        "submission_type": "VIDEO",
        "estimated_duration": "5 mins",
        "order_index": 2,
    },
    {
        "code": "SPT-READ-PASSAGE",
        "title": "Today's Reading: Quiet Morning",
        "description": "Read the short peaceful story aloud at your own comfortable pace.",
        "instructions": (
            "Read the peaceful story passage shown below out loud. "
            "When you are done, tap Record and tell us one or two things you read about in your own words."
        ),
        "reading_passage": (
            "The morning sun rose warmly over the green garden. "
            "Two cheerful sparrows were chirping happily in the branches of the flowering neem tree. "
            "Fresh white jasmine blossoms opened up, spreading a sweet and soothing fragrance all around the courtyard. "
            "It was a peaceful and serene start to a brand new day."
        ),
        "visual_steps": [
            {"step": 1, "title": "Get comfortable", "detail": "Sit in a well-lit spot with your glasses if needed.", "icon": "light_mode"},
            {"step": 2, "title": "Read the story", "detail": "Read the short paragraph aloud at your own pace.", "icon": "menu_book"},
            {"step": 3, "title": "Share your thoughts", "detail": "Tap Record and tell us what you remember from the story.", "icon": "mic"},
        ],
        "task_category": "READING",
        "difficulty": "EASY",
        "submission_type": "AUDIO",
        "estimated_duration": "7 mins",
        "order_index": 3,
    },
    {
        "code": "SPT-REFLECT-READING",
        "title": "Reflect on a Story or News",
        "description": "Share a thought about a book, newspaper article, or poem you like.",
        "instructions": (
            "Think about a favorite story, a newspaper headline, or a poem you read recently. "
            "Record a short voice note describing who was in the story or what happened."
        ),
        "visual_steps": [
            {"step": 1, "title": "Pick a memory", "detail": "Think about something interesting you read recently.", "icon": "psychology"},
            {"step": 2, "title": "Organize thought", "detail": "Remember the key persons, places, or event.", "icon": "record_voice_over"},
            {"step": 3, "title": "Record voice note", "detail": "Speak comfortably into the phone microphone.", "icon": "mic"},
        ],
        "task_category": "READING",
        "difficulty": "EASY",
        "submission_type": "AUDIO",
        "estimated_duration": "5 mins",
        "order_index": 4,
    },
    {
        "code": "SPT-DRAW-FLOWER",
        "title": "Today's Drawing: A Simple Flower",
        "description": "Draw a cheerful flower on a sheet of paper with pencil or crayons.",
        "instructions": (
            "Take a blank piece of paper and a pencil or crayon. "
            "Draw a small circle in the middle. "
            "Add 5 rounded petals all around it. "
            "Draw a stem with one or two green leaves. "
            "Take a clear photo of your drawing and upload it."
        ),
        "visual_steps": [
            {"step": 1, "title": "Prepare paper", "detail": "Place a plain paper and pencil on your table.", "icon": "edit"},
            {"step": 2, "title": "Center & petals", "detail": "Draw a round circle, then 5 gentle petals around it.", "icon": "local_florist"},
            {"step": 3, "title": "Stem & leaves", "detail": "Draw a straight stem downwards with 2 small leaves.", "icon": "eco"},
            {"step": 4, "title": "Snap a photo", "detail": "Hold your phone steady and photograph the drawing.", "icon": "photo_camera"},
        ],
        "task_category": "DRAWING",
        "difficulty": "EASY",
        "submission_type": "PHOTO",
        "estimated_duration": "8 mins",
        "order_index": 5,
    },
    {
        "code": "SPT-DRAW-HOUSE",
        "title": "Today's Drawing: A Cozy House",
        "description": "Draw a friendly home with a square wall, triangle roof, and a door.",
        "instructions": (
            "Draw a square on paper for the house walls. "
            "Add a triangle on top for the roof. "
            "Draw a rectangular door and a square window. "
            "You can color the roof or walls if you like! Take a photo of the completed drawing."
        ),
        "visual_steps": [
            {"step": 1, "title": "Square walls", "detail": "Draw a neat square in the center of your page.", "icon": "crop_square"},
            {"step": 2, "title": "Triangle roof", "detail": "Draw a triangle resting on top of the square.", "icon": "change_history"},
            {"step": 3, "title": "Door & window", "detail": "Add a small rectangular door and a window.", "icon": "home"},
            {"step": 4, "title": "Take a picture", "detail": "Capture a clear photo of your finished house.", "icon": "photo_camera"},
        ],
        "task_category": "DRAWING",
        "difficulty": "EASY",
        "submission_type": "PHOTO",
        "estimated_duration": "8 mins",
        "order_index": 6,
    },
    {
        "code": "SPT-DRAW-PATTERN",
        "title": "Copy a Shape Pattern",
        "description": "Draw three basic geometric shapes: Circle, Triangle, and Square.",
        "instructions": (
            "On a clean sheet of paper, draw three shapes in a line: "
            "1. A Circle ⭕  2. A Triangle 🔺  3. A Square 🟦. "
            "Take your time to draw each shape clearly side by side."
        ),
        "visual_steps": [
            {"step": 1, "title": "Observe pattern", "detail": "Look at the 3 shapes: Circle, Triangle, Square.", "icon": "category"},
            {"step": 2, "title": "Draw on paper", "detail": "Draw them in the same order from left to right.", "icon": "draw"},
            {"step": 3, "title": "Photograph", "detail": "Take a photo of your three hand-drawn shapes.", "icon": "photo_camera"},
        ],
        "task_category": "DRAWING",
        "difficulty": "EASY",
        "submission_type": "PHOTO",
        "estimated_duration": "5 mins",
        "order_index": 7,
    },
    {
        "code": "SPT-ORGANIZE-TABLE",
        "title": "Organize Your Table Space",
        "description": "Arrange the items on your study or dining table neatly in place.",
        "instructions": (
            "Choose a small table or desk. "
            "Stack any books or papers straight, place pens in a holder or cup, "
            "and leave the surface clean and orderly. "
            "Take a photo showing your neat arrangement."
        ),
        "visual_steps": [
            {"step": 1, "title": "Inspect table", "detail": "Notice the scattered items on your table.", "icon": "table_restaurant"},
            {"step": 2, "title": "Stack papers", "detail": "Place books and papers in a neat, straight stack.", "icon": "auto_stories"},
            {"step": 3, "title": "Group items", "detail": "Gather pens, coasters, and small items neatly.", "icon": "border_all"},
            {"step": 4, "title": "Take photo", "detail": "Photograph your calm, organized tabletop.", "icon": "photo_camera"},
        ],
        "task_category": "ORGANIZATION",
        "difficulty": "EASY",
        "submission_type": "PHOTO",
        "estimated_duration": "5 mins",
        "order_index": 8,
    },
    {
        "code": "SPT-SORT-ITEMS",
        "title": "Sort Everyday Household Objects",
        "description": "Group 4-6 small household items into two separate categories.",
        "instructions": (
            "Pick 4 to 6 familiar items at home (e.g. 2 spoons and 2 pens, or handkerchiefs and socks). "
            "Place them into two separate groups on your table. "
            "Take a picture of the two sorted groups side by side."
        ),
        "visual_steps": [
            {"step": 1, "title": "Gather items", "detail": "Collect 4 to 6 small items (e.g. pens and spoons).", "icon": "pan_tool"},
            {"step": 2, "title": "Group 1", "detail": "Put writing items on the left side.", "icon": "edit_note"},
            {"step": 3, "title": "Group 2", "detail": "Put utensils/kitchen items on the right side.", "icon": "restaurant"},
            {"step": 4, "title": "Photograph", "detail": "Take a photo of both groups clearly separated.", "icon": "photo_camera"},
        ],
        "task_category": "SIMPLE_HOUSEHOLD_ACTIVITY",
        "difficulty": "EASY",
        "submission_type": "PHOTO",
        "estimated_duration": "6 mins",
        "order_index": 9,
    },
    {
        "code": "SPT-MEMORY-OBJECTS",
        "title": "Look, Remember & Name",
        "description": "Look at 3 familiar items, remember them, and describe them in voice note.",
        "instructions": (
            "Look closely at these 3 items: [1. A Red Apple 🍎, 2. A Shiny Key 🔑, 3. A Blue Pen 🖊️]. "
            "Study them for 10 seconds, then close your eyes. "
            "Tap Record and name all 3 objects and their colors aloud."
        ),
        "visual_steps": [
            {"step": 1, "title": "Observe items", "detail": "Look at: Red Apple 🍎, Shiny Key 🔑, Blue Pen 🖊️.", "icon": "visibility"},
            {"step": 2, "title": "Remember", "detail": "Close your eyes and visualize all 3 items.", "icon": "psychology"},
            {"step": 3, "title": "Record voice note", "detail": "Press record and tell us the 3 objects you recalled.", "icon": "mic"},
        ],
        "task_category": "MEMORY",
        "difficulty": "EASY",
        "submission_type": "AUDIO",
        "estimated_duration": "5 mins",
        "order_index": 10,
    },
    {
        "code": "SPT-MUSIC-HUMMING",
        "title": "Sing or Hum a Familiar Tune",
        "description": "Hum or sing a gentle melody from a familiar song or lullaby.",
        "instructions": (
            "Think of a peaceful song you know well (such as a traditional lullaby, devotional melody, or old favorite). "
            "Hum or sing a line or two gently for 10-15 seconds. "
            "Record a short voice note of your humming."
        ),
        "visual_steps": [
            {"step": 1, "title": "Choose melody", "detail": "Think of a calming song you have known for years.", "icon": "music_note"},
            {"step": 2, "title": "Breathe gently", "detail": "Relax and hum the tune softly.", "icon": "hearing"},
            {"step": 3, "title": "Record audio", "detail": "Record 10-15 seconds of your gentle singing or humming.", "icon": "mic"},
        ],
        "task_category": "MUSIC",
        "difficulty": "EASY",
        "submission_type": "AUDIO",
        "estimated_duration": "5 mins",
        "order_index": 11,
    },
    {
        "code": "SPT-LINEUP-OBJECTS",
        "title": "Arrange 5 Objects in a Row",
        "description": "Find 5 small objects and line them up from smallest to largest.",
        "instructions": (
            "Find 5 small objects at home (e.g. coin, button, eraser, pen, small notebook). "
            "Arrange them in a straight horizontal row on a table, starting with the smallest on the left "
            "and ending with the largest on the right. Take a picture of your row."
        ),
        "visual_steps": [
            {"step": 1, "title": "Collect 5 items", "detail": "Pick 5 safe objects of differing sizes.", "icon": "grid_view"},
            {"step": 2, "title": "Arrange by size", "detail": "Place smallest on left, largest on right in a line.", "icon": "format_line_spacing"},
            {"step": 3, "title": "Take photo", "detail": "Take a photo showing all 5 objects in order.", "icon": "photo_camera"},
        ],
        "task_category": "ORGANIZATION",
        "difficulty": "EASY",
        "submission_type": "PHOTO",
        "estimated_duration": "7 mins",
        "order_index": 12,
    },
    {
        "code": "SPT-OBSERVE-SCENE",
        "title": "Look Outside and Describe",
        "description": "Look through a window or at a wall picture, and describe what you see.",
        "instructions": (
            "Look through your nearest window or at a family photograph on the wall. "
            "Notice the colors, objects, or faces. "
            "Tap Record and tell us 2 or 3 pleasant things you observe."
        ),
        "visual_steps": [
            {"step": 1, "title": "Look around", "detail": "Look out the window at trees and sky or at a picture.", "icon": "window"},
            {"step": 2, "title": "Notice details", "detail": "Observe colors, daylight, and objects.", "icon": "visibility"},
            {"step": 3, "title": "Record voice note", "detail": "Speak for a few seconds describing what you see.", "icon": "mic"},
        ],
        "task_category": "OBSERVATION",
        "difficulty": "EASY",
        "submission_type": "AUDIO",
        "estimated_duration": "5 mins",
        "order_index": 13,
    },
    {
        "code": "SPT-WRITE-THOUGHT",
        "title": "Handwriting: A Positive Thought",
        "description": "Write down a peaceful sentence neatly on paper with a pen.",
        "instructions": (
            "Take a sheet of paper and a pen. "
            "Write the sentence: 'Today is a peaceful and beautiful day.' "
            "You may write in English, Telugu, Hindi, or any language you prefer. "
            "Take a clear photo of your handwriting."
        ),
        "visual_steps": [
            {"step": 1, "title": "Pen & paper", "detail": "Place your paper flat on a firm surface.", "icon": "note_alt"},
            {"step": 2, "title": "Write sentence", "detail": "Write: 'Today is a peaceful and beautiful day.'", "icon": "history_edu"},
            {"step": 3, "title": "Photograph", "detail": "Take a clear picture of the paper and upload it.", "icon": "photo_camera"},
        ],
        "task_category": "COMMUNICATION",
        "difficulty": "EASY",
        "submission_type": "PHOTO",
        "estimated_duration": "5 mins",
        "order_index": 14,
    },
    {
        "code": "SPT-MATCH-PAIRS",
        "title": "Match 3 Pairs of Household Items",
        "description": "Find 3 pairs of matching items (such as spoons, pens, or socks) and pair them.",
        "instructions": (
            "Find 3 pairs of matching items from home (e.g. 2 identical spoons, 2 matching pens, 2 socks). "
            "Place each pair together side by side on a flat surface. "
            "Take a photo of all 3 matched pairs."
        ),
        "visual_steps": [
            {"step": 1, "title": "Find pairs", "detail": "Find 3 matching pairs (e.g. spoons, pens, socks).", "icon": "filter_2"},
            {"step": 2, "title": "Pair up", "detail": "Place the matched items side-by-side neatly.", "icon": "view_column"},
            {"step": 3, "title": "Take photo", "detail": "Take a clear photo showing the 3 pairs.", "icon": "photo_camera"},
        ],
        "task_category": "SIMPLE_HOUSEHOLD_ACTIVITY",
        "difficulty": "EASY",
        "submission_type": "PHOTO",
        "estimated_duration": "6 mins",
        "order_index": 15,
    },
]


def seed_tasks():
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    try:
        created_count = 0
        for item in SAMPLE_TEMPLATES:
            existing = db.query(DailyTaskTemplate).filter(
                DailyTaskTemplate.code == item["code"]
            ).first()
            if not existing:
                template = DailyTaskTemplate(
                    code=item["code"],
                    title=item["title"],
                    description=item["description"],
                    instructions=item["instructions"],
                    visual_steps=item["visual_steps"],
                    task_category=item["task_category"],
                    difficulty=item["difficulty"],
                    submission_type=item["submission_type"],
                    estimated_duration=item["estimated_duration"],
                    reading_passage=item.get("reading_passage"),
                    order_index=item["order_index"],
                )
                db.add(template)
                created_count += 1

        db.commit()
        print(f"Seeded {created_count} new Daily SPT task templates successfully.")
    finally:
        db.close()


if __name__ == "__main__":
    seed_tasks()
