import json
import rblxopencloud
from datetime import datetime
from typing import TypedDict

EXPERIENCE_ID = 3743131673
DATASTORE_API_KEY = "eGXkWWK4fEyh9oTdKvFtfehP1qGGSk5C8Nn+Z7GMqAkTwWrj"
MAIN_DS_NAME = "PlayerData_2.1"
REBIRTH_LEADERBOARD_ODS_NAME = "RebirthsLeaderboard2"
DATA_STORE_SCOPE = "global"
MINIMUM_REBIRTH = 5
REFACTOR_UNIX_TICK = 1687300260

class KeyData(TypedDict):
	user_id: int
	scope: str
	value: int

experience = rblxopencloud.Experience(EXPERIENCE_ID, api_key=DATASTORE_API_KEY)
rebirth_ods = experience.get_ordered_data_store(REBIRTH_LEADERBOARD_ODS_NAME, scope=DATA_STORE_SCOPE)
main_ds = experience.get_data_store(MAIN_DS_NAME, scope=DATA_STORE_SCOPE)

key_data_list: list[KeyData] = []
for key in rebirth_ods.sort_keys(
	descending = True,
	min = MINIMUM_REBIRTH,
):
	key_data_list.append({
		"user_id": int(key.key),
		"scope": key.scope,
		"value": key.value,
	})

player_data_registry = {}
for key_data in key_data_list:
	main_key = str(key_data["user_id"])
	player_data, entry_info = main_ds.get(main_key)

	max_ts: int | None = None
	total_money: float | None = None
	if "TimerRewardList" in player_data:
		for reward_data in player_data["TimerRewardList"]:
			if "Sessions" in reward_data:
				for session_data in reward_data["Sessions"]:
					if "FinishTimestamp" in session_data:
						max_ts = session_data["FinishTimestamp"]

	if "TotalMoney" in player_data:
		total_money = player_data["TotalMoney"]

	if max_ts != None and max_ts > REFACTOR_UNIX_TICK:
		player_data_registry[main_key] = {
			"key": key_data,
			"data": player_data,
			"last_visit": max_ts,
			"total_money": total_money,
		}

print(f"cheater count: {len(player_data_registry.keys())}")

deletion_confirmed = input(f"delete the data of {len(player_data_registry.keys())} suspected cheaters? [y/n]: ")

if deletion_confirmed == "y":
	with open("scripts/deleted_data.json", "w") as dump_file:
		dump_file.write(json.dumps(player_data_registry, indent=5))

	for user_key in player_data_registry.keys():
		print(f"resetting: {user_key}")
		rebirth_ods.remove(user_key)
		main_ds.remove(user_key)
else:
	print("deletion cancelled")