import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import uuid
import random

np.random.seed(42)

NUM_PLAYERS = 20000
START_DATE = datetime(2024, 1, 1)
EXPERIMENT_ID = "tutorial_v2_test"

players = [f"player_{i}" for i in range(NUM_PLAYERS)]
events = []

def random_time(base, minutes=1440):
    return base + timedelta(minutes=random.randint(1, minutes))

for player in players:
    install_time = random_time(START_DATE)
    variant = np.random.choice(["control", "treatment"])
    
    # INSTALL
    events.append({
        "player_id": player,
        "event_time": install_time,
        "event_name": "install",
        "session_id": str(uuid.uuid4()),
        "level": None,
        "revenue": 0.0,
        "experiment_id": EXPERIMENT_ID,
        "variant": variant
    })
    
    # TUTORIAL
    tutorial_prob = 0.70 if variant == "control" else 0.78
    tutorial_completed = np.random.rand() < tutorial_prob

    if tutorial_completed:
        tutorial_time = random_time(install_time)
        events.append({
            "player_id": player,
            "event_time": tutorial_time,
            "event_name": "tutorial_complete",
            "session_id": str(uuid.uuid4()),
            "level": None,
            "revenue": 0.0,
            "experiment_id": EXPERIMENT_ID,
            "variant": variant
        })

        # LEVEL PROGRESSION
        max_level = np.random.choice([3, 5, 10], p=[0.4, 0.4, 0.2])
        for lvl in range(1, max_level + 1):
            if np.random.rand() < 0.85:
                events.append({
                    "player_id": player,
                    "event_time": random_time(tutorial_time),
                    "event_name": "level_complete",
                    "session_id": str(uuid.uuid4()),
                    "level": lvl,
                    "revenue": 0.0,
                    "experiment_id": EXPERIMENT_ID,
                    "variant": variant
                })

    # RETENTION PROBABILITIES
    d1_prob = 0.35 if variant == "control" else 0.42
    d7_prob = 0.18 if variant == "control" else 0.24
    d30_prob = 0.08 if variant == "control" else 0.12

    retained_d1 = np.random.rand() < d1_prob
    retained_d7 = retained_d1 and (np.random.rand() < d7_prob)
    retained_d30 = retained_d7 and (np.random.rand() < d30_prob)

    if retained_d1:
        events.append({
            "player_id": player,
            "event_time": install_time + timedelta(days=1, minutes=random.randint(0, 1440)),
            "event_name": "session_start",
            "session_id": str(uuid.uuid4()),
            "level": None,
            "revenue": 0.0,
            "experiment_id": EXPERIMENT_ID,
            "variant": variant
        })

    if retained_d7:
        events.append({
            "player_id": player,
            "event_time": install_time + timedelta(days=7, minutes=random.randint(0, 1440)),
            "event_name": "session_start",
            "session_id": str(uuid.uuid4()),
            "level": None,
            "revenue": 0.0,
            "experiment_id": EXPERIMENT_ID,
            "variant": variant
        })

    if retained_d30:
        events.append({
            "player_id": player,
            "event_time": install_time + timedelta(days=30, minutes=random.randint(0, 1440)),
            "event_name": "session_start",
            "session_id": str(uuid.uuid4()),
            "level": None,
            "revenue": 0.0,
            "experiment_id": EXPERIMENT_ID,
            "variant": variant
        })

    # PURCHASE
    purchase_prob = 0.03 if variant == "control" else 0.045
    if np.random.rand() < purchase_prob:
        events.append({
            "player_id": player,
            "event_time": random_time(install_time, 10080),
            "event_name": "purchase",
            "session_id": str(uuid.uuid4()),
            "level": None,
            "revenue": np.random.choice([1.99, 4.99, 9.99]),
            "experiment_id": EXPERIMENT_ID,
            "variant": variant
        })

df = pd.DataFrame(events)
df = df.sort_values("event_time")
df.to_csv("game_events.csv", index=False)

print("game_events.csv with retention events generated successfully")
