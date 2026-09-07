def calculate_next_difficulty(current_difficulty: int, accuracy: float) -> int:
    """
    Calculate the next game difficulty based on the patient's accuracy.

    Difficulty levels:
        1 = Easy
        2 = Medium
        3 = Hard

    Rules:
        Accuracy >= 80%  -> Increase difficulty
        Accuracy <= 50%  -> Decrease difficulty
        Otherwise        -> Keep the same difficulty
    """

    # Make sure difficulty stays between 1 and 3
    current_difficulty = max(1, min(3, current_difficulty))

    if accuracy >= 80:
        next_difficulty = current_difficulty + 1

    elif accuracy <= 50:
        next_difficulty = current_difficulty - 1

    else:
        next_difficulty = current_difficulty

    # Prevent difficulty from going below 1 or above 3
    next_difficulty = max(1, min(3, next_difficulty))

    return next_difficulty