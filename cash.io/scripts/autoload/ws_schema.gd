# ws_schema.gd
extends Node
class_name ws_schema
# schema.gd

enum Topic {
	UNSPECIFIED = 0,
	PING = 1,
	PONG = 2,
	GET_ROOMS = 3,
	ROOMS_JOIN = 4,
	ROOMS_REJOIN = 5,
	ROOMS_JOINED = 6,
	ROOMS_PLAYER_SETTLED = 7,
	ROOMS_PLAYER_ELIMINATED = 8,
	WALLET_UPDATED = 9,
	ROOMS_CASHOUT_REJECTED = 10,
	ROOMS_POWERUP_UPDATED = 11,
	ROOMS_SNAPSHOT = 12,
	ROOMS_TIME_LEFT = 13,
	ROOMS_INPUT = 14,
	ROOMS_LEAVE = 15,
	ROOMS_DISCONNECT = 16,
	ROOMS_POWERUP_USE = 17,
	DEPOSITS_CREATE = 18,
	WITHDRAWALS_CREATE = 19,
	WITHDRAWALS_ACCOUNT_STATUS = 20,
	GET_ME = 21,
	SET_AVATAR = 22,
	GET_SHOP_CATALOG = 23,
	BUY_CATALOG_ITEM = 24
}

class ErrorBody:
	var message: String = ""

class StringBody:
	var value: String = ""
	func to_dict():
		return {
			"value": value
		}

class NumberBody:
	var value: int = 0
	func to_dict():
		return {
			"value": value
		}

class PowerupBody:
	var id: String = ""
	var name: String = ""
	var quantity: int = 0
	func to_dict():
		return {
			"id": id,
			"name": name,
			"quantity": quantity,
		}

class InputBody:
	var dx: int = 0
	var dy: int = 0
	var input_seq: int = 0
	func to_dict():
		return {
			"dx": dx,
			"dy": dy,
			"input_seq": input_seq
		}

class GetMeBody:
	var fields: String = ""

class SetAvatarBody:
	var avatar: String = ""
	func to_dict():
		return {
			"avatar": avatar
		}

class CreateDepositBody:
	var amount_minor: int = 0
	var provider: String = ""
	func to_dict():
		return{
			"amount_minor": amount_minor,
			"provider": provider
		}

class DepositCreatedBody:
	var checkout_url: String = ""

class WithdrawalBankDetailsBody:
	var account_name: String = ""
	var account_number: String = ""
	var bank_name: String = ""
	func to_dict():
		return{
			"account_name": account_name,
			"account_number": account_number,
			"bank_name": bank_name
		}

class CreateWithdrawalBody:
	var amount_minor: int = 0
	var provider: String = ""
	var crypto_address: String = ""
	var bank_details: WithdrawalBankDetailsBody = null
	func to_dict():
		return {
			"amount_minor": amount_minor,
			"provider": provider,
			"crypto_address": crypto_address,
			"bank_details": bank_details.to_dict() if bank_details != null else null
		}

class WithdrawalAccountStatusBody:
	var value: bool = false

class InventoryItem:
	var id: String = ""
	var code: String = ""
	var name: String = ""
	var quantity: int = 0

class UserPayload:
	var user_id: String = ""
	var username: String = ""
	var email: String = ""
	var wallet_balance: int = 0
	var active_avatar: String = ""
	var owned_avatars: Array[String] = []
	var inventory: Array[InventoryItem] = []

class ShopCatalogItem:
	var id: String = ""
	var name: String = ""
	var price: int = 0

class ShopCatalog:
	var items: Array[ShopCatalogItem] = []

class BuyCatalogItemBody:
	var item_id: String = ""
	func to_dict():
		return {
			"item_id": item_id
		}

class RoomItem:
	var id: String = ""
	var min_stake: int = 0

class Rooms:
	var items: Array[RoomItem] = []
	func to_dict():
		var arr = []
		for item in items:
			arr.append(item.to_dict())

		return {
			"items": arr
		}

class Bounds:
	var width: float = 0.0
	var height: float = 0.0

class Entity:
	var id: String = ""
	var username: String = ""
	var opcode: String = ""
	var x: float = 0.0
	var y: float = 0.0
	var coins: int = 0
	var mass: float = 0.0
	var appearance: String = ""

class InitialPowerup:
	var id: String = ""
	var name: String = ""
	var quantity: int = 0

class InitialPayload:
	var bounds: Bounds = Bounds.new()
	var players: Array[Entity] = []
	var pellets: Array[Entity] = []
	var powerups: Array[InitialPowerup] = []
	var remaining_sec: int = 0

class SnapshotPlayer:
	var id: String = ""
	var x: float = 0.0
	var y: float = 0.0
	var coins: int = 0
	var mass: float = 0.0

class SnapshotPayload:
	var bounds: Bounds = Bounds.new()
	var updated_players: Array[SnapshotPlayer] = []
	var spawned_players: Array[Entity] = []
	var removed_players: Array[String] = []
	var spawned_pellets: Array[Entity] = []
	var removed_pellets: Array[String] = []

class Envelope:
	var topic: int = Topic.UNSPECIFIED
	var room_id: String = ""

	var rooms: Rooms = null
	var error_body: ErrorBody = null
	var initial_payload: InitialPayload = null
	var number_body: NumberBody = null
	var powerup_body: PowerupBody = null
	var snapshot_payload: SnapshotPayload = null
	var input_body: InputBody = null
	var create_deposit_body: CreateDepositBody = null
	var create_withdrawal_body: CreateWithdrawalBody = null
	var user_payload: UserPayload = null
	var shop_catalog: ShopCatalog = null
	var get_me_body: GetMeBody = null
	var set_avatar_body: SetAvatarBody = null
	var deposit_created_body: DepositCreatedBody = null
	var buy_catalog_item_body: BuyCatalogItemBody = null
	var string_body: StringBody = null
	var withdrawal_account_status_body: WithdrawalAccountStatusBody = null

	func to_dict():
		var data = {
			"topic": topic,
		}
	
		if room_id != "":
			data["room_id"] = room_id
		if input_body != null:
			data["input_body"] = input_body.to_dict()
		if powerup_body != null:
			data["powerup_body"] = powerup_body.to_dict()
		if create_deposit_body != null:
			data["create_deposit_body"] = create_deposit_body.to_dict()
		if create_withdrawal_body != null:
			data["create_withdrawal_body"] = create_withdrawal_body.to_dict()
		if buy_catalog_item_body != null:
			data["buy_catalog_item_body"] = buy_catalog_item_body.to_dict()
		if string_body != null:
			data["string_body"] = string_body.to_dict()

		if number_body != null:
			data["number_body"] = number_body.to_dict()

		# add others as needed

		return data
