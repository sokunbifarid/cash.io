# Package: cashio.ws
#extends Node
#class_name ws_proto
# Package: cashio.ws
# Package: cashio.ws

const GDScriptUtils = preload("res://addons/protobuf/proto/GDScriptUtils.gd")
const Message = preload("res://addons/protobuf/proto/Message.gd")

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
	BUY_CATALOG_ITEM = 24,
} 
 
class ErrorBody extends Message:
	#1 : message
	var message: String = ""


	## Init message field values to default value
	func Init() -> void:
		self.message = ""

	## Create a new message instance
	## Returns: Message - New message instance
	func New() -> Message:
		var msg = ErrorBody.new()
		return msg

	## Message ProtoName
	## Returns: String - ProtoName
	func ProtoName() -> String:
		return "cashio.ws.ErrorBody"

	func MergeFrom(other : Message) -> void:
		if other is ErrorBody:
			self.message += other.message
 
	func SerializeToBytes(buffer: PackedByteArray = PackedByteArray()) -> PackedByteArray:
		if self.message != "":
			GDScriptUtils.encode_tag(buffer, 1, 9)
			GDScriptUtils.encode_string(buffer, self.message)
		return buffer
 
	func ParseFromBytes(data: PackedByteArray) -> int:
		var size = data.size()
		var pos = 0
 
		while pos < size:
			var tag = GDScriptUtils.decode_tag(data, pos)
			var field_number = tag[GDScriptUtils.VALUE_KEY]
			pos += tag[GDScriptUtils.SIZE_KEY]
 
			match field_number:
				1:
					var field_value = GDScriptUtils.decode_string(data, pos, self)
					self.message = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				_:
					pass

		return pos

	func SerializeToDictionary() -> Dictionary:
		var dict = {}
		dict["message"] = self.message
		return dict

	func ParseFromDictionary(dict: Dictionary) -> void:
		if dict == null:
			return

		if dict.has("message"):
			self.message = dict.get("message")

# =========================================

class StringBody extends Message:
	#1 : value
	var value: String = ""


	## Init message field values to default value
	func Init() -> void:
		self.value = ""

	## Create a new message instance
	## Returns: Message - New message instance
	func New() -> Message:
		var msg = StringBody.new()
		return msg

	## Message ProtoName
	## Returns: String - ProtoName
	func ProtoName() -> String:
		return "cashio.ws.StringBody"

	func MergeFrom(other : Message) -> void:
		if other is StringBody:
			self.value += other.value
 
	func SerializeToBytes(buffer: PackedByteArray = PackedByteArray()) -> PackedByteArray:
		if self.value != "":
			GDScriptUtils.encode_tag(buffer, 1, 9)
			GDScriptUtils.encode_string(buffer, self.value)
		return buffer
 
	func ParseFromBytes(data: PackedByteArray) -> int:
		var size = data.size()
		var pos = 0
 
		while pos < size:
			var tag = GDScriptUtils.decode_tag(data, pos)
			var field_number = tag[GDScriptUtils.VALUE_KEY]
			pos += tag[GDScriptUtils.SIZE_KEY]
 
			match field_number:
				1:
					var field_value = GDScriptUtils.decode_string(data, pos, self)
					self.value = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				_:
					pass

		return pos

	func SerializeToDictionary() -> Dictionary:
		var dict = {}
		dict["value"] = self.value
		return dict

	func ParseFromDictionary(dict: Dictionary) -> void:
		if dict == null:
			return

		if dict.has("value"):
			self.value = dict.get("value")

# =========================================

class NumberBody extends Message:
	#1 : value
	var value: int = 0


	## Init message field values to default value
	func Init() -> void:
		self.value = 0

	## Create a new message instance
	## Returns: Message - New message instance
	func New() -> Message:
		var msg = NumberBody.new()
		return msg

	## Message ProtoName
	## Returns: String - ProtoName
	func ProtoName() -> String:
		return "cashio.ws.NumberBody"

	func MergeFrom(other : Message) -> void:
		if other is NumberBody:
			self.value += other.value
 
	func SerializeToBytes(buffer: PackedByteArray = PackedByteArray()) -> PackedByteArray:
		if self.value != 0:
			GDScriptUtils.encode_tag(buffer, 1, 3)
			GDScriptUtils.encode_varint(buffer, self.value)
		return buffer
 
	func ParseFromBytes(data: PackedByteArray) -> int:
		var size = data.size()
		var pos = 0
 
		while pos < size:
			var tag = GDScriptUtils.decode_tag(data, pos)
			var field_number = tag[GDScriptUtils.VALUE_KEY]
			pos += tag[GDScriptUtils.SIZE_KEY]
 
			match field_number:
				1:
					var field_value = GDScriptUtils.decode_varint(data, pos, self)
					self.value = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				_:
					pass

		return pos

	func SerializeToDictionary() -> Dictionary:
		var dict = {}
		dict["value"] = self.value
		return dict

	func ParseFromDictionary(dict: Dictionary) -> void:
		if dict == null:
			return

		if dict.has("value"):
			self.value = dict.get("value")

# =========================================

class PowerupBody extends Message:
	#1 : id
	var id: String = ""

	#2 : name
	var name: String = ""

	#3 : quantity
	var quantity: int = 0


	## Init message field values to default value
	func Init() -> void:
		self.id = ""
		self.name = ""
		self.quantity = 0

	## Create a new message instance
	## Returns: Message - New message instance
	func New() -> Message:
		var msg = PowerupBody.new()
		return msg

	## Message ProtoName
	## Returns: String - ProtoName
	func ProtoName() -> String:
		return "cashio.ws.PowerupBody"

	func MergeFrom(other : Message) -> void:
		if other is PowerupBody:
			self.id += other.id
			self.name += other.name
			self.quantity += other.quantity
 
	func SerializeToBytes(buffer: PackedByteArray = PackedByteArray()) -> PackedByteArray:
		if self.id != "":
			GDScriptUtils.encode_tag(buffer, 1, 9)
			GDScriptUtils.encode_string(buffer, self.id)
		if self.name != "":
			GDScriptUtils.encode_tag(buffer, 2, 9)
			GDScriptUtils.encode_string(buffer, self.name)
		if self.quantity != 0:
			GDScriptUtils.encode_tag(buffer, 3, 3)
			GDScriptUtils.encode_varint(buffer, self.quantity)
		return buffer
 
	func ParseFromBytes(data: PackedByteArray) -> int:
		var size = data.size()
		var pos = 0
 
		while pos < size:
			var tag = GDScriptUtils.decode_tag(data, pos)
			var field_number = tag[GDScriptUtils.VALUE_KEY]
			pos += tag[GDScriptUtils.SIZE_KEY]
 
			match field_number:
				1:
					var field_value = GDScriptUtils.decode_string(data, pos, self)
					self.id = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				2:
					var field_value = GDScriptUtils.decode_string(data, pos, self)
					self.name = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				3:
					var field_value = GDScriptUtils.decode_varint(data, pos, self)
					self.quantity = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				_:
					pass

		return pos

	func SerializeToDictionary() -> Dictionary:
		var dict = {}
		dict["id"] = self.id
		dict["name"] = self.name
		dict["quantity"] = self.quantity
		return dict

	func ParseFromDictionary(dict: Dictionary) -> void:
		if dict == null:
			return

		if dict.has("id"):
			self.id = dict.get("id")
		if dict.has("name"):
			self.name = dict.get("name")
		if dict.has("quantity"):
			self.quantity = dict.get("quantity")

# =========================================

class InputBody extends Message:
	#1 : dx
	var dx: int = 0

	#2 : dy
	var dy: int = 0


	## Init message field values to default value
	func Init() -> void:
		self.dx = 0
		self.dy = 0

	## Create a new message instance
	## Returns: Message - New message instance
	func New() -> Message:
		var msg = InputBody.new()
		return msg

	## Message ProtoName
	## Returns: String - ProtoName
	func ProtoName() -> String:
		return "cashio.ws.InputBody"

	func MergeFrom(other : Message) -> void:
		if other is InputBody:
			self.dx += other.dx
			self.dy += other.dy
 
	func SerializeToBytes(buffer: PackedByteArray = PackedByteArray()) -> PackedByteArray:
		if self.dx != 0:
			GDScriptUtils.encode_tag(buffer, 1, 17)
			GDScriptUtils.encode_zigzag32(buffer, self.dx)
		if self.dy != 0:
			GDScriptUtils.encode_tag(buffer, 2, 17)
			GDScriptUtils.encode_zigzag32(buffer, self.dy)
		return buffer
 
	func ParseFromBytes(data: PackedByteArray) -> int:
		var size = data.size()
		var pos = 0
 
		while pos < size:
			var tag = GDScriptUtils.decode_tag(data, pos)
			var field_number = tag[GDScriptUtils.VALUE_KEY]
			pos += tag[GDScriptUtils.SIZE_KEY]
 
			match field_number:
				1:
					var field_value = GDScriptUtils.decode_zigzag32(data, pos, self)
					self.dx = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				2:
					var field_value = GDScriptUtils.decode_zigzag32(data, pos, self)
					self.dy = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				_:
					pass

		return pos

	func SerializeToDictionary() -> Dictionary:
		var dict = {}
		dict["dx"] = self.dx
		dict["dy"] = self.dy
		return dict

	func ParseFromDictionary(dict: Dictionary) -> void:
		if dict == null:
			return

		if dict.has("dx"):
			self.dx = dict.get("dx")
		if dict.has("dy"):
			self.dy = dict.get("dy")

# =========================================

class GetMeBody extends Message:
	#1 : fields
	var fields: String = ""


	## Init message field values to default value
	func Init() -> void:
		self.fields = ""

	## Create a new message instance
	## Returns: Message - New message instance
	func New() -> Message:
		var msg = GetMeBody.new()
		return msg

	## Message ProtoName
	## Returns: String - ProtoName
	func ProtoName() -> String:
		return "cashio.ws.GetMeBody"

	func MergeFrom(other : Message) -> void:
		if other is GetMeBody:
			self.fields += other.fields
 
	func SerializeToBytes(buffer: PackedByteArray = PackedByteArray()) -> PackedByteArray:
		if self.fields != "":
			GDScriptUtils.encode_tag(buffer, 1, 9)
			GDScriptUtils.encode_string(buffer, self.fields)
		return buffer
 
	func ParseFromBytes(data: PackedByteArray) -> int:
		var size = data.size()
		var pos = 0
 
		while pos < size:
			var tag = GDScriptUtils.decode_tag(data, pos)
			var field_number = tag[GDScriptUtils.VALUE_KEY]
			pos += tag[GDScriptUtils.SIZE_KEY]
 
			match field_number:
				1:
					var field_value = GDScriptUtils.decode_string(data, pos, self)
					self.fields = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				_:
					pass

		return pos

	func SerializeToDictionary() -> Dictionary:
		var dict = {}
		dict["fields"] = self.fields
		return dict

	func ParseFromDictionary(dict: Dictionary) -> void:
		if dict == null:
			return

		if dict.has("fields"):
			self.fields = dict.get("fields")

# =========================================

class SetAvatarBody extends Message:
	#1 : avatar
	var avatar: String = ""


	## Init message field values to default value
	func Init() -> void:
		self.avatar = ""

	## Create a new message instance
	## Returns: Message - New message instance
	func New() -> Message:
		var msg = SetAvatarBody.new()
		return msg

	## Message ProtoName
	## Returns: String - ProtoName
	func ProtoName() -> String:
		return "cashio.ws.SetAvatarBody"

	func MergeFrom(other : Message) -> void:
		if other is SetAvatarBody:
			self.avatar += other.avatar
 
	func SerializeToBytes(buffer: PackedByteArray = PackedByteArray()) -> PackedByteArray:
		if self.avatar != "":
			GDScriptUtils.encode_tag(buffer, 1, 9)
			GDScriptUtils.encode_string(buffer, self.avatar)
		return buffer
 
	func ParseFromBytes(data: PackedByteArray) -> int:
		var size = data.size()
		var pos = 0
 
		while pos < size:
			var tag = GDScriptUtils.decode_tag(data, pos)
			var field_number = tag[GDScriptUtils.VALUE_KEY]
			pos += tag[GDScriptUtils.SIZE_KEY]
 
			match field_number:
				1:
					var field_value = GDScriptUtils.decode_string(data, pos, self)
					self.avatar = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				_:
					pass

		return pos

	func SerializeToDictionary() -> Dictionary:
		var dict = {}
		dict["avatar"] = self.avatar
		return dict

	func ParseFromDictionary(dict: Dictionary) -> void:
		if dict == null:
			return

		if dict.has("avatar"):
			self.avatar = dict.get("avatar")

# =========================================

class CreateDepositBody extends Message:
	#1 : amount_minor
	var amount_minor: int = 0

	#2 : provider
	var provider: String = ""


	## Init message field values to default value
	func Init() -> void:
		self.amount_minor = 0
		self.provider = ""

	## Create a new message instance
	## Returns: Message - New message instance
	func New() -> Message:
		var msg = CreateDepositBody.new()
		return msg

	## Message ProtoName
	## Returns: String - ProtoName
	func ProtoName() -> String:
		return "cashio.ws.CreateDepositBody"

	func MergeFrom(other : Message) -> void:
		if other is CreateDepositBody:
			self.amount_minor += other.amount_minor
			self.provider += other.provider
 
	func SerializeToBytes(buffer: PackedByteArray = PackedByteArray()) -> PackedByteArray:
		if self.amount_minor != 0:
			GDScriptUtils.encode_tag(buffer, 1, 3)
			GDScriptUtils.encode_varint(buffer, self.amount_minor)
		if self.provider != "":
			GDScriptUtils.encode_tag(buffer, 2, 9)
			GDScriptUtils.encode_string(buffer, self.provider)
		return buffer
 
	func ParseFromBytes(data: PackedByteArray) -> int:
		var size = data.size()
		var pos = 0
 
		while pos < size:
			var tag = GDScriptUtils.decode_tag(data, pos)
			var field_number = tag[GDScriptUtils.VALUE_KEY]
			pos += tag[GDScriptUtils.SIZE_KEY]
 
			match field_number:
				1:
					var field_value = GDScriptUtils.decode_varint(data, pos, self)
					self.amount_minor = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				2:
					var field_value = GDScriptUtils.decode_string(data, pos, self)
					self.provider = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				_:
					pass

		return pos

	func SerializeToDictionary() -> Dictionary:
		var dict = {}
		dict["amount_minor"] = self.amount_minor
		dict["provider"] = self.provider
		return dict

	func ParseFromDictionary(dict: Dictionary) -> void:
		if dict == null:
			return

		if dict.has("amount_minor"):
			self.amount_minor = dict.get("amount_minor")
		if dict.has("provider"):
			self.provider = dict.get("provider")

# =========================================

class DepositCreatedBody extends Message:
	#1 : checkout_url
	var checkout_url: String = ""


	## Init message field values to default value
	func Init() -> void:
		self.checkout_url = ""

	## Create a new message instance
	## Returns: Message - New message instance
	func New() -> Message:
		var msg = DepositCreatedBody.new()
		return msg

	## Message ProtoName
	## Returns: String - ProtoName
	func ProtoName() -> String:
		return "cashio.ws.DepositCreatedBody"

	func MergeFrom(other : Message) -> void:
		if other is DepositCreatedBody:
			self.checkout_url += other.checkout_url
 
	func SerializeToBytes(buffer: PackedByteArray = PackedByteArray()) -> PackedByteArray:
		if self.checkout_url != "":
			GDScriptUtils.encode_tag(buffer, 1, 9)
			GDScriptUtils.encode_string(buffer, self.checkout_url)
		return buffer
 
	func ParseFromBytes(data: PackedByteArray) -> int:
		var size = data.size()
		var pos = 0
 
		while pos < size:
			var tag = GDScriptUtils.decode_tag(data, pos)
			var field_number = tag[GDScriptUtils.VALUE_KEY]
			pos += tag[GDScriptUtils.SIZE_KEY]
 
			match field_number:
				1:
					var field_value = GDScriptUtils.decode_string(data, pos, self)
					self.checkout_url = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				_:
					pass

		return pos

	func SerializeToDictionary() -> Dictionary:
		var dict = {}
		dict["checkout_url"] = self.checkout_url
		return dict

	func ParseFromDictionary(dict: Dictionary) -> void:
		if dict == null:
			return

		if dict.has("checkout_url"):
			self.checkout_url = dict.get("checkout_url")

# =========================================

class WithdrawalBankDetailsBody extends Message:
	#1 : account_name
	var account_name: String = ""

	#2 : account_number
	var account_number: String = ""

	#3 : bank_name
	var bank_name: String = ""


	## Init message field values to default value
	func Init() -> void:
		self.account_name = ""
		self.account_number = ""
		self.bank_name = ""

	## Create a new message instance
	## Returns: Message - New message instance
	func New() -> Message:
		var msg = WithdrawalBankDetailsBody.new()
		return msg

	## Message ProtoName
	## Returns: String - ProtoName
	func ProtoName() -> String:
		return "cashio.ws.WithdrawalBankDetailsBody"

	func MergeFrom(other : Message) -> void:
		if other is WithdrawalBankDetailsBody:
			self.account_name += other.account_name
			self.account_number += other.account_number
			self.bank_name += other.bank_name
 
	func SerializeToBytes(buffer: PackedByteArray = PackedByteArray()) -> PackedByteArray:
		if self.account_name != "":
			GDScriptUtils.encode_tag(buffer, 1, 9)
			GDScriptUtils.encode_string(buffer, self.account_name)
		if self.account_number != "":
			GDScriptUtils.encode_tag(buffer, 2, 9)
			GDScriptUtils.encode_string(buffer, self.account_number)
		if self.bank_name != "":
			GDScriptUtils.encode_tag(buffer, 3, 9)
			GDScriptUtils.encode_string(buffer, self.bank_name)
		return buffer
 
	func ParseFromBytes(data: PackedByteArray) -> int:
		var size = data.size()
		var pos = 0
 
		while pos < size:
			var tag = GDScriptUtils.decode_tag(data, pos)
			var field_number = tag[GDScriptUtils.VALUE_KEY]
			pos += tag[GDScriptUtils.SIZE_KEY]
 
			match field_number:
				1:
					var field_value = GDScriptUtils.decode_string(data, pos, self)
					self.account_name = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				2:
					var field_value = GDScriptUtils.decode_string(data, pos, self)
					self.account_number = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				3:
					var field_value = GDScriptUtils.decode_string(data, pos, self)
					self.bank_name = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				_:
					pass

		return pos

	func SerializeToDictionary() -> Dictionary:
		var dict = {}
		dict["account_name"] = self.account_name
		dict["account_number"] = self.account_number
		dict["bank_name"] = self.bank_name
		return dict

	func ParseFromDictionary(dict: Dictionary) -> void:
		if dict == null:
			return

		if dict.has("account_name"):
			self.account_name = dict.get("account_name")
		if dict.has("account_number"):
			self.account_number = dict.get("account_number")
		if dict.has("bank_name"):
			self.bank_name = dict.get("bank_name")

# =========================================

class CreateWithdrawalBody extends Message:
	#1 : amount_minor
	var amount_minor: int = 0

	#2 : provider
	var provider: String = ""

	#3 : crypto_address
	var crypto_address: String = ""

	#4 : bank_details
	var bank_details: WithdrawalBankDetailsBody = null


	## Init message field values to default value
	func Init() -> void:
		self.amount_minor = 0
		self.provider = ""
		self.crypto_address = ""
		if self.bank_details != null:			self.bank_details.clear()

	## Create a new message instance
	## Returns: Message - New message instance
	func New() -> Message:
		var msg = CreateWithdrawalBody.new()
		return msg

	## Message ProtoName
	## Returns: String - ProtoName
	func ProtoName() -> String:
		return "cashio.ws.CreateWithdrawalBody"

	func MergeFrom(other : Message) -> void:
		if other is CreateWithdrawalBody:
			self.amount_minor += other.amount_minor
			self.provider += other.provider
			self.crypto_address += other.crypto_address
			if other.bank_details != null:
				if self.bank_details == null:
					self.bank_details = WithdrawalBankDetailsBody.new()
				self.bank_details.MergeFrom(other.bank_details)
			else:
				self.bank_details = null
 
	func SerializeToBytes(buffer: PackedByteArray = PackedByteArray()) -> PackedByteArray:
		if self.amount_minor != 0:
			GDScriptUtils.encode_tag(buffer, 1, 3)
			GDScriptUtils.encode_varint(buffer, self.amount_minor)
		if self.provider != "":
			GDScriptUtils.encode_tag(buffer, 2, 9)
			GDScriptUtils.encode_string(buffer, self.provider)
		if self.crypto_address != "":
			GDScriptUtils.encode_tag(buffer, 3, 9)
			GDScriptUtils.encode_string(buffer, self.crypto_address)
		if self.bank_details != null:
			GDScriptUtils.encode_tag(buffer, 4, 11)
			GDScriptUtils.encode_message(buffer, self.bank_details)
		return buffer
 
	func ParseFromBytes(data: PackedByteArray) -> int:
		var size = data.size()
		var pos = 0
 
		while pos < size:
			var tag = GDScriptUtils.decode_tag(data, pos)
			var field_number = tag[GDScriptUtils.VALUE_KEY]
			pos += tag[GDScriptUtils.SIZE_KEY]
 
			match field_number:
				1:
					var field_value = GDScriptUtils.decode_varint(data, pos, self)
					self.amount_minor = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				2:
					var field_value = GDScriptUtils.decode_string(data, pos, self)
					self.provider = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				3:
					var field_value = GDScriptUtils.decode_string(data, pos, self)
					self.crypto_address = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				4:
					if self.bank_details == null:
						self.bank_details = WithdrawalBankDetailsBody.new()
					self.bank_details.Init()
					var field_value = GDScriptUtils.decode_message(data, pos, self.bank_details)
					self.bank_details = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				_:
					pass

		return pos

	func SerializeToDictionary() -> Dictionary:
		var dict = {}
		dict["amount_minor"] = self.amount_minor
		dict["provider"] = self.provider
		dict["crypto_address"] = self.crypto_address
		if self.bank_details != null:
			dict["bank_details"] = self.bank_details.SerializeToDictionary()
		return dict

	func ParseFromDictionary(dict: Dictionary) -> void:
		if dict == null:
			return

		if dict.has("amount_minor"):
			self.amount_minor = dict.get("amount_minor")
		if dict.has("provider"):
			self.provider = dict.get("provider")
		if dict.has("crypto_address"):
			self.crypto_address = dict.get("crypto_address")
		if dict.has("bank_details"):
			if self.bank_details == null:
				self.bank_details = WithdrawalBankDetailsBody.new()
			self.bank_details.Init()
			self.bank_details.ParseFromDictionary(dict.get("bank_details"))
		else:
			self.bank_details = null

# =========================================

class WithdrawalAccountStatusBody extends Message:
	#1 : value
	var value: bool = false


	## Init message field values to default value
	func Init() -> void:
		self.value = false

	## Create a new message instance
	## Returns: Message - New message instance
	func New() -> Message:
		var msg = WithdrawalAccountStatusBody.new()
		return msg

	## Message ProtoName
	## Returns: String - ProtoName
	func ProtoName() -> String:
		return "cashio.ws.WithdrawalAccountStatusBody"

	func MergeFrom(other : Message) -> void:
		if other is WithdrawalAccountStatusBody:
			self.value = other.value
 
	func SerializeToBytes(buffer: PackedByteArray = PackedByteArray()) -> PackedByteArray:
		if self.value != false:
			GDScriptUtils.encode_tag(buffer, 1, 8)
			GDScriptUtils.encode_bool(buffer, self.value)
		return buffer
 
	func ParseFromBytes(data: PackedByteArray) -> int:
		var size = data.size()
		var pos = 0
 
		while pos < size:
			var tag = GDScriptUtils.decode_tag(data, pos)
			var field_number = tag[GDScriptUtils.VALUE_KEY]
			pos += tag[GDScriptUtils.SIZE_KEY]
 
			match field_number:
				1:
					var field_value = GDScriptUtils.decode_bool(data, pos, self)
					self.value = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				_:
					pass

		return pos

	func SerializeToDictionary() -> Dictionary:
		var dict = {}
		dict["value"] = self.value
		return dict

	func ParseFromDictionary(dict: Dictionary) -> void:
		if dict == null:
			return

		if dict.has("value"):
			self.value = dict.get("value")

# =========================================

class InventoryItem extends Message:
	#1 : id
	var id: String = ""

	#2 : code
	var code: String = ""

	#3 : name
	var name: String = ""

	#4 : quantity
	var quantity: int = 0


	## Init message field values to default value
	func Init() -> void:
		self.id = ""
		self.code = ""
		self.name = ""
		self.quantity = 0

	## Create a new message instance
	## Returns: Message - New message instance
	func New() -> Message:
		var msg = InventoryItem.new()
		return msg

	## Message ProtoName
	## Returns: String - ProtoName
	func ProtoName() -> String:
		return "cashio.ws.InventoryItem"

	func MergeFrom(other : Message) -> void:
		if other is InventoryItem:
			self.id += other.id
			self.code += other.code
			self.name += other.name
			self.quantity += other.quantity
 
	func SerializeToBytes(buffer: PackedByteArray = PackedByteArray()) -> PackedByteArray:
		if self.id != "":
			GDScriptUtils.encode_tag(buffer, 1, 9)
			GDScriptUtils.encode_string(buffer, self.id)
		if self.code != "":
			GDScriptUtils.encode_tag(buffer, 2, 9)
			GDScriptUtils.encode_string(buffer, self.code)
		if self.name != "":
			GDScriptUtils.encode_tag(buffer, 3, 9)
			GDScriptUtils.encode_string(buffer, self.name)
		if self.quantity != 0:
			GDScriptUtils.encode_tag(buffer, 4, 3)
			GDScriptUtils.encode_varint(buffer, self.quantity)
		return buffer
 
	func ParseFromBytes(data: PackedByteArray) -> int:
		var size = data.size()
		var pos = 0
 
		while pos < size:
			var tag = GDScriptUtils.decode_tag(data, pos)
			var field_number = tag[GDScriptUtils.VALUE_KEY]
			pos += tag[GDScriptUtils.SIZE_KEY]
 
			match field_number:
				1:
					var field_value = GDScriptUtils.decode_string(data, pos, self)
					self.id = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				2:
					var field_value = GDScriptUtils.decode_string(data, pos, self)
					self.code = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				3:
					var field_value = GDScriptUtils.decode_string(data, pos, self)
					self.name = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				4:
					var field_value = GDScriptUtils.decode_varint(data, pos, self)
					self.quantity = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				_:
					pass

		return pos

	func SerializeToDictionary() -> Dictionary:
		var dict = {}
		dict["id"] = self.id
		dict["code"] = self.code
		dict["name"] = self.name
		dict["quantity"] = self.quantity
		return dict

	func ParseFromDictionary(dict: Dictionary) -> void:
		if dict == null:
			return

		if dict.has("id"):
			self.id = dict.get("id")
		if dict.has("code"):
			self.code = dict.get("code")
		if dict.has("name"):
			self.name = dict.get("name")
		if dict.has("quantity"):
			self.quantity = dict.get("quantity")

# =========================================

class UserPayload extends Message:
	#1 : user_id
	var user_id: String = ""

	#2 : username
	var username: String = ""

	#3 : email
	var email: String = ""

	#4 : wallet_balance
	var wallet_balance: int = 0

	#5 : active_avatar
	var active_avatar: String = ""

	#6 : owned_avatars
	var _owned_avatars: Array[String] = []
	var _owned_avatars_size: int = 0
	## Size of _owned_avatars
	func owned_avatars_size() -> int:
		return self._owned_avatars_size
	## Get _owned_avatars
	func owned_avatars() -> Array[String]:
		return self._owned_avatars.slice(0, self._owned_avatars_size)
	## Get _owned_avatars item 
	func get_owned_avatars(index: int) -> String: # index begin from 1
		if index > 0 and index <= _owned_avatars_size and index <= _owned_avatars.size():
			return self._owned_avatars[index - 1]
		return ""
	## Add _owned_avatars
	func add_owned_avatars(item: String) -> String:
		if self._owned_avatars_size >= 0 and self._owned_avatars_size < self._owned_avatars.size():
			self._owned_avatars[self._owned_avatars_size] = item
		else:
			self._owned_avatars.append(item)
		self._owned_avatars_size += 1
		return item
	## Append _owned_avatars
	func append_owned_avatars(item_array: Array):
		for item in item_array:
			if item is String:
				self.add_owned_avatars(item)
	## Clean _owned_avatars 
	func clear_owned_avatars() -> void:
		self._owned_avatars_size = 0

	#7 : inventory
	var _inventory: Array[InventoryItem] = []
	var _inventory_size: int = 0
	## Size of _inventory
	func inventory_size() -> int:
		return self._inventory_size
	## Get _inventory
	func inventory() -> Array[InventoryItem]:
		return self._inventory.slice(0, self._inventory_size)
	## Get _inventory item 
	func get_inventory(index: int) -> InventoryItem: # index begin from 1
		if index > 0 and index <= _inventory_size and index <= _inventory.size():
			return self._inventory[index - 1]
		return null
	## Add _inventory
	func add_inventory(item: InventoryItem) -> InventoryItem:
		if self._inventory_size >= 0 and self._inventory_size < self._inventory.size():
			self._inventory[self._inventory_size] = item
		else:
			self._inventory.append(item)
		self._inventory_size += 1
		return item
	## Append _inventory
	func append_inventory(item_array: Array):
		for item in item_array:
			if item is InventoryItem:
				self.add_inventory(item)
	## Clean _inventory 
	func clear_inventory() -> void:
		self._inventory_size = 0


	## Init message field values to default value
	func Init() -> void:
		self.user_id = ""
		self.username = ""
		self.email = ""
		self.wallet_balance = 0
		self.active_avatar = ""
		self.clear_owned_avatars
		self.clear_inventory

	## Create a new message instance
	## Returns: Message - New message instance
	func New() -> Message:
		var msg = UserPayload.new()
		return msg

	## Message ProtoName
	## Returns: String - ProtoName
	func ProtoName() -> String:
		return "cashio.ws.UserPayload"

	func MergeFrom(other : Message) -> void:
		if other is UserPayload:
			self.user_id += other.user_id
			self.username += other.username
			self.email += other.email
			self.wallet_balance += other.wallet_balance
			self.active_avatar += other.active_avatar
			self._owned_avatars = self._owned_avatars.slice(0, _owned_avatars_size)
			self._owned_avatars.append_array(other._owned_avatars.slice(0, other._owned_avatars_size))
			self._owned_avatars_size += other._owned_avatars_size
			self._inventory = self._inventory.slice(0, _inventory_size)
			self._inventory.append_array(other._inventory.slice(0, other._inventory_size))
			self._inventory_size += other._inventory_size
 
	func SerializeToBytes(buffer: PackedByteArray = PackedByteArray()) -> PackedByteArray:
		if self.user_id != "":
			GDScriptUtils.encode_tag(buffer, 1, 9)
			GDScriptUtils.encode_string(buffer, self.user_id)
		if self.username != "":
			GDScriptUtils.encode_tag(buffer, 2, 9)
			GDScriptUtils.encode_string(buffer, self.username)
		if self.email != "":
			GDScriptUtils.encode_tag(buffer, 3, 9)
			GDScriptUtils.encode_string(buffer, self.email)
		if self.wallet_balance != 0:
			GDScriptUtils.encode_tag(buffer, 4, 3)
			GDScriptUtils.encode_varint(buffer, self.wallet_balance)
		if self.active_avatar != "":
			GDScriptUtils.encode_tag(buffer, 5, 9)
			GDScriptUtils.encode_string(buffer, self.active_avatar)
		for item in self._owned_avatars:
			GDScriptUtils.encode_tag(buffer, 6, 9)
			GDScriptUtils.encode_string(buffer, item)
		for item in self._inventory:
			GDScriptUtils.encode_tag(buffer, 7, 11)
			GDScriptUtils.encode_message(buffer, item)
		return buffer
 
	func ParseFromBytes(data: PackedByteArray) -> int:
		var size = data.size()
		var pos = 0
 
		while pos < size:
			var tag = GDScriptUtils.decode_tag(data, pos)
			var field_number = tag[GDScriptUtils.VALUE_KEY]
			pos += tag[GDScriptUtils.SIZE_KEY]
 
			match field_number:
				1:
					var field_value = GDScriptUtils.decode_string(data, pos, self)
					self.user_id = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				2:
					var field_value = GDScriptUtils.decode_string(data, pos, self)
					self.username = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				3:
					var field_value = GDScriptUtils.decode_string(data, pos, self)
					self.email = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				4:
					var field_value = GDScriptUtils.decode_varint(data, pos, self)
					self.wallet_balance = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				5:
					var field_value = GDScriptUtils.decode_string(data, pos, self)
					self.active_avatar = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				6:
					var field_value = GDScriptUtils.decode_string(data, pos, self)
					self.add_owned_avatars(field_value[GDScriptUtils.VALUE_KEY])
					pos += field_value[GDScriptUtils.SIZE_KEY]
				7:
					var sub__inventory = InventoryItem.new()
					var field_value = GDScriptUtils.decode_message(data, pos, sub__inventory)
					self.add_inventory(field_value[GDScriptUtils.VALUE_KEY])
					pos += field_value[GDScriptUtils.SIZE_KEY]
				_:
					pass

		return pos

	func SerializeToDictionary() -> Dictionary:
		var dict = {}
		dict["user_id"] = self.user_id
		dict["username"] = self.username
		dict["email"] = self.email
		dict["wallet_balance"] = self.wallet_balance
		dict["active_avatar"] = self.active_avatar
		dict["owned_avatars"] = self._owned_avatars
		dict["inventory"] = []
		for index in range(1, self._inventory_size + 1):
			var item = self.get_inventory(index)
			dict["inventory"].append(item.SerializeToDictionary())
		return dict

	func ParseFromDictionary(dict: Dictionary) -> void:
		if dict == null:
			return

		if dict.has("user_id"):
			self.user_id = dict.get("user_id")
		if dict.has("username"):
			self.username = dict.get("username")
		if dict.has("email"):
			self.email = dict.get("email")
		if dict.has("wallet_balance"):
			self.wallet_balance = dict.get("wallet_balance")
		if dict.has("active_avatar"):
			self.active_avatar = dict.get("active_avatar")
		self.clear_owned_avatars()
		if dict.has("owned_avatars"):
			var list = dict["owned_avatars"]
			for item in list:
				self.add_owned_avatars(item)
		self.clear_inventory()
		if dict.has("inventory"):
			var list = dict["inventory"]
			for item in list:
				var item_msg = InventoryItem.new()
				item_msg.ParseFromDictionary(item)
				self.add_inventory(item_msg)

# =========================================

class ShopCatalog extends Message:
	#1 : items
	var _items: Array[ShopCatalog.Item] = []
	var _items_size: int = 0
	## Size of _items
	func items_size() -> int:
		return self._items_size
	## Get _items
	func items() -> Array[ShopCatalog.Item]:
		return self._items.slice(0, self._items_size)
	## Get _items item 
	func get_items(index: int) -> ShopCatalog.Item: # index begin from 1
		if index > 0 and index <= _items_size and index <= _items.size():
			return self._items[index - 1]
		return null
	## Add _items
	func add_items(item: ShopCatalog.Item) -> ShopCatalog.Item:
		if self._items_size >= 0 and self._items_size < self._items.size():
			self._items[self._items_size] = item
		else:
			self._items.append(item)
		self._items_size += 1
		return item
	## Append _items
	func append_items(item_array: Array):
		for item in item_array:
			if item is ShopCatalog.Item:
				self.add_items(item)
	## Clean _items 
	func clear_items() -> void:
		self._items_size = 0

	class Item extends Message:
		#1 : id
		var id: String = ""

		#2 : name
		var name: String = ""

		#3 : price
		var price: int = 0


		## Init message field values to default value
		func Init() -> void:
			self.id = ""
			self.name = ""
			self.price = 0

		## Create a new message instance
		## Returns: Message - New message instance
		func New() -> Message:
			var msg = Item.new()
			return msg

		## Message ProtoName
		## Returns: String - ProtoName
		func ProtoName() -> String:
			return "cashio.ws.Item"

		func MergeFrom(other : Message) -> void:
			if other is Item:
				self.id += other.id
				self.name += other.name
				self.price += other.price
 
		func SerializeToBytes(buffer: PackedByteArray = PackedByteArray()) -> PackedByteArray:
			if self.id != "":
				GDScriptUtils.encode_tag(buffer, 1, 9)
				GDScriptUtils.encode_string(buffer, self.id)
			if self.name != "":
				GDScriptUtils.encode_tag(buffer, 2, 9)
				GDScriptUtils.encode_string(buffer, self.name)
			if self.price != 0:
				GDScriptUtils.encode_tag(buffer, 3, 3)
				GDScriptUtils.encode_varint(buffer, self.price)
			return buffer
 
		func ParseFromBytes(data: PackedByteArray) -> int:
			var size = data.size()
			var pos = 0
 
			while pos < size:
				var tag = GDScriptUtils.decode_tag(data, pos)
				var field_number = tag[GDScriptUtils.VALUE_KEY]
				pos += tag[GDScriptUtils.SIZE_KEY]
 
				match field_number:
					1:
						var field_value = GDScriptUtils.decode_string(data, pos, self)
						self.id = field_value[GDScriptUtils.VALUE_KEY]
						pos += field_value[GDScriptUtils.SIZE_KEY]
					2:
						var field_value = GDScriptUtils.decode_string(data, pos, self)
						self.name = field_value[GDScriptUtils.VALUE_KEY]
						pos += field_value[GDScriptUtils.SIZE_KEY]
					3:
						var field_value = GDScriptUtils.decode_varint(data, pos, self)
						self.price = field_value[GDScriptUtils.VALUE_KEY]
						pos += field_value[GDScriptUtils.SIZE_KEY]
					_:
						pass

			return pos

		func SerializeToDictionary() -> Dictionary:
			var dict = {}
			dict["id"] = self.id
			dict["name"] = self.name
			dict["price"] = self.price
			return dict

		func ParseFromDictionary(dict: Dictionary) -> void:
			if dict == null:
				return

			if dict.has("id"):
				self.id = dict.get("id")
			if dict.has("name"):
				self.name = dict.get("name")
			if dict.has("price"):
				self.price = dict.get("price")


	## Init message field values to default value
	func Init() -> void:
		self.clear_items

	## Create a new message instance
	## Returns: Message - New message instance
	func New() -> Message:
		var msg = ShopCatalog.new()
		return msg

	## Message ProtoName
	## Returns: String - ProtoName
	func ProtoName() -> String:
		return "cashio.ws.ShopCatalog"

	func MergeFrom(other : Message) -> void:
		if other is ShopCatalog:
			self._items = self._items.slice(0, _items_size)
			self._items.append_array(other._items.slice(0, other._items_size))
			self._items_size += other._items_size
 
	func SerializeToBytes(buffer: PackedByteArray = PackedByteArray()) -> PackedByteArray:
		for item in self._items:
			GDScriptUtils.encode_tag(buffer, 1, 11)
			GDScriptUtils.encode_message(buffer, item)
		return buffer
 
	func ParseFromBytes(data: PackedByteArray) -> int:
		var size = data.size()
		var pos = 0
 
		while pos < size:
			var tag = GDScriptUtils.decode_tag(data, pos)
			var field_number = tag[GDScriptUtils.VALUE_KEY]
			pos += tag[GDScriptUtils.SIZE_KEY]
 
			match field_number:
				1:
					var sub__items = ShopCatalog.Item.new()
					var field_value = GDScriptUtils.decode_message(data, pos, sub__items)
					self.add_items(field_value[GDScriptUtils.VALUE_KEY])
					pos += field_value[GDScriptUtils.SIZE_KEY]
				_:
					pass

		return pos

	func SerializeToDictionary() -> Dictionary:
		var dict = {}
		dict["items"] = []
		for index in range(1, self._items_size + 1):
			var item = self.get_items(index)
			dict["items"].append(item.SerializeToDictionary())
		return dict

	func ParseFromDictionary(dict: Dictionary) -> void:
		if dict == null:
			return

		self.clear_items()
		if dict.has("items"):
			var list = dict["items"]
			for item in list:
				var item_msg = ShopCatalog.Item.new()
				item_msg.ParseFromDictionary(item)
				self.add_items(item_msg)

# =========================================

class BuyCatalogItemBody extends Message:
	#1 : item_id
	var item_id: String = ""


	## Init message field values to default value
	func Init() -> void:
		self.item_id = ""

	## Create a new message instance
	## Returns: Message - New message instance
	func New() -> Message:
		var msg = BuyCatalogItemBody.new()
		return msg

	## Message ProtoName
	## Returns: String - ProtoName
	func ProtoName() -> String:
		return "cashio.ws.BuyCatalogItemBody"

	func MergeFrom(other : Message) -> void:
		if other is BuyCatalogItemBody:
			self.item_id += other.item_id
 
	func SerializeToBytes(buffer: PackedByteArray = PackedByteArray()) -> PackedByteArray:
		if self.item_id != "":
			GDScriptUtils.encode_tag(buffer, 1, 9)
			GDScriptUtils.encode_string(buffer, self.item_id)
		return buffer
 
	func ParseFromBytes(data: PackedByteArray) -> int:
		var size = data.size()
		var pos = 0
 
		while pos < size:
			var tag = GDScriptUtils.decode_tag(data, pos)
			var field_number = tag[GDScriptUtils.VALUE_KEY]
			pos += tag[GDScriptUtils.SIZE_KEY]
 
			match field_number:
				1:
					var field_value = GDScriptUtils.decode_string(data, pos, self)
					self.item_id = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				_:
					pass

		return pos

	func SerializeToDictionary() -> Dictionary:
		var dict = {}
		dict["item_id"] = self.item_id
		return dict

	func ParseFromDictionary(dict: Dictionary) -> void:
		if dict == null:
			return

		if dict.has("item_id"):
			self.item_id = dict.get("item_id")

# =========================================

class Rooms extends Message:
	#1 : items
	var _items: Array[Rooms.Item] = []
	var _items_size: int = 0
	## Size of _items
	func items_size() -> int:
		return self._items_size
	## Get _items
	func items() -> Array[Rooms.Item]:
		return self._items.slice(0, self._items_size)
	## Get _items item 
	func get_items(index: int) -> Rooms.Item: # index begin from 1
		if index > 0 and index <= _items_size and index <= _items.size():
			return self._items[index - 1]
		return null
	## Add _items
	func add_items(item: Rooms.Item) -> Rooms.Item:
		if self._items_size >= 0 and self._items_size < self._items.size():
			self._items[self._items_size] = item
		else:
			self._items.append(item)
		self._items_size += 1
		return item
	## Append _items
	func append_items(item_array: Array):
		for item in item_array:
			if item is Rooms.Item:
				self.add_items(item)
	## Clean _items 
	func clear_items() -> void:
		self._items_size = 0

	class Item extends Message:
		#1 : id
		var id: String = ""

		#2 : min_stake
		var min_stake: int = 0


		## Init message field values to default value
		func Init() -> void:
			self.id = ""
			self.min_stake = 0

		## Create a new message instance
		## Returns: Message - New message instance
		func New() -> Message:
			var msg = Item.new()
			return msg

		## Message ProtoName
		## Returns: String - ProtoName
		func ProtoName() -> String:
			return "cashio.ws.Item"

		func MergeFrom(other : Message) -> void:
			if other is Item:
				self.id += other.id
				self.min_stake += other.min_stake
 
		func SerializeToBytes(buffer: PackedByteArray = PackedByteArray()) -> PackedByteArray:
			if self.id != "":
				GDScriptUtils.encode_tag(buffer, 1, 9)
				GDScriptUtils.encode_string(buffer, self.id)
			if self.min_stake != 0:
				GDScriptUtils.encode_tag(buffer, 2, 3)
				GDScriptUtils.encode_varint(buffer, self.min_stake)
			return buffer
 
		func ParseFromBytes(data: PackedByteArray) -> int:
			var size = data.size()
			var pos = 0
 
			while pos < size:
				var tag = GDScriptUtils.decode_tag(data, pos)
				var field_number = tag[GDScriptUtils.VALUE_KEY]
				pos += tag[GDScriptUtils.SIZE_KEY]
 
				match field_number:
					1:
						var field_value = GDScriptUtils.decode_string(data, pos, self)
						self.id = field_value[GDScriptUtils.VALUE_KEY]
						pos += field_value[GDScriptUtils.SIZE_KEY]
					2:
						var field_value = GDScriptUtils.decode_varint(data, pos, self)
						self.min_stake = field_value[GDScriptUtils.VALUE_KEY]
						pos += field_value[GDScriptUtils.SIZE_KEY]
					_:
						pass

			return pos

		func SerializeToDictionary() -> Dictionary:
			var dict = {}
			dict["id"] = self.id
			dict["min_stake"] = self.min_stake
			return dict

		func ParseFromDictionary(dict: Dictionary) -> void:
			if dict == null:
				return

			if dict.has("id"):
				self.id = dict.get("id")
			if dict.has("min_stake"):
				self.min_stake = dict.get("min_stake")


	## Init message field values to default value
	func Init() -> void:
		self.clear_items

	## Create a new message instance
	## Returns: Message - New message instance
	func New() -> Message:
		var msg = Rooms.new()
		return msg

	## Message ProtoName
	## Returns: String - ProtoName
	func ProtoName() -> String:
		return "cashio.ws.Rooms"

	func MergeFrom(other : Message) -> void:
		if other is Rooms:
			self._items = self._items.slice(0, _items_size)
			self._items.append_array(other._items.slice(0, other._items_size))
			self._items_size += other._items_size
 
	func SerializeToBytes(buffer: PackedByteArray = PackedByteArray()) -> PackedByteArray:
		for item in self._items:
			GDScriptUtils.encode_tag(buffer, 1, 11)
			GDScriptUtils.encode_message(buffer, item)
		return buffer
 
	func ParseFromBytes(data: PackedByteArray) -> int:
		var size = data.size()
		var pos = 0
 
		while pos < size:
			var tag = GDScriptUtils.decode_tag(data, pos)
			var field_number = tag[GDScriptUtils.VALUE_KEY]
			pos += tag[GDScriptUtils.SIZE_KEY]
 
			match field_number:
				1:
					var sub__items = Rooms.Item.new()
					var field_value = GDScriptUtils.decode_message(data, pos, sub__items)
					self.add_items(field_value[GDScriptUtils.VALUE_KEY])
					pos += field_value[GDScriptUtils.SIZE_KEY]
				_:
					pass

		return pos

	func SerializeToDictionary() -> Dictionary:
		var dict = {}
		dict["items"] = []
		for index in range(1, self._items_size + 1):
			var item = self.get_items(index)
			dict["items"].append(item.SerializeToDictionary())
		return dict

	func ParseFromDictionary(dict: Dictionary) -> void:
		if dict == null:
			return

		self.clear_items()
		if dict.has("items"):
			var list = dict["items"]
			for item in list:
				var item_msg = Rooms.Item.new()
				item_msg.ParseFromDictionary(item)
				self.add_items(item_msg)

# =========================================

class Bounds extends Message:
	#1 : width
	var width: float = 0.0

	#2 : height
	var height: float = 0.0


	## Init message field values to default value
	func Init() -> void:
		self.width = 0.0
		self.height = 0.0

	## Create a new message instance
	## Returns: Message - New message instance
	func New() -> Message:
		var msg = Bounds.new()
		return msg

	## Message ProtoName
	## Returns: String - ProtoName
	func ProtoName() -> String:
		return "cashio.ws.Bounds"

	func MergeFrom(other : Message) -> void:
		if other is Bounds:
			self.width += other.width
			self.height += other.height
 
	func SerializeToBytes(buffer: PackedByteArray = PackedByteArray()) -> PackedByteArray:
		if self.width != 0.0:
			GDScriptUtils.encode_tag(buffer, 1, 1)
			GDScriptUtils.encode_double(buffer, self.width)
		if self.height != 0.0:
			GDScriptUtils.encode_tag(buffer, 2, 1)
			GDScriptUtils.encode_double(buffer, self.height)
		return buffer
 
	func ParseFromBytes(data: PackedByteArray) -> int:
		var size = data.size()
		var pos = 0
 
		while pos < size:
			var tag = GDScriptUtils.decode_tag(data, pos)
			var field_number = tag[GDScriptUtils.VALUE_KEY]
			pos += tag[GDScriptUtils.SIZE_KEY]
 
			match field_number:
				1:
					var field_value = GDScriptUtils.decode_double(data, pos, self)
					self.width = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				2:
					var field_value = GDScriptUtils.decode_double(data, pos, self)
					self.height = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				_:
					pass

		return pos

	func SerializeToDictionary() -> Dictionary:
		var dict = {}
		dict["width"] = self.width
		dict["height"] = self.height
		return dict

	func ParseFromDictionary(dict: Dictionary) -> void:
		if dict == null:
			return

		if dict.has("width"):
			self.width = dict.get("width")
		if dict.has("height"):
			self.height = dict.get("height")

# =========================================

class Entity extends Message:
	#1 : id
	var id: String = ""

	#2 : username
	var username: String = ""

	#3 : opcode
	var opcode: String = ""

	#4 : x
	var x: float = 0.0

	#5 : y
	var y: float = 0.0

	#6 : coins
	var coins: int = 0

	#7 : mass
	var mass: float = 0.0

	#8 : appearance
	var appearance: String = ""


	## Init message field values to default value
	func Init() -> void:
		self.id = ""
		self.username = ""
		self.opcode = ""
		self.x = 0.0
		self.y = 0.0
		self.coins = 0
		self.mass = 0.0
		self.appearance = ""

	## Create a new message instance
	## Returns: Message - New message instance
	func New() -> Message:
		var msg = Entity.new()
		return msg

	## Message ProtoName
	## Returns: String - ProtoName
	func ProtoName() -> String:
		return "cashio.ws.Entity"

	func MergeFrom(other : Message) -> void:
		if other is Entity:
			self.id += other.id
			self.username += other.username
			self.opcode += other.opcode
			self.x += other.x
			self.y += other.y
			self.coins += other.coins
			self.mass += other.mass
			self.appearance += other.appearance
 
	func SerializeToBytes(buffer: PackedByteArray = PackedByteArray()) -> PackedByteArray:
		if self.id != "":
			GDScriptUtils.encode_tag(buffer, 1, 9)
			GDScriptUtils.encode_string(buffer, self.id)
		if self.username != "":
			GDScriptUtils.encode_tag(buffer, 2, 9)
			GDScriptUtils.encode_string(buffer, self.username)
		if self.opcode != "":
			GDScriptUtils.encode_tag(buffer, 3, 9)
			GDScriptUtils.encode_string(buffer, self.opcode)
		if self.x != 0.0:
			GDScriptUtils.encode_tag(buffer, 4, 1)
			GDScriptUtils.encode_double(buffer, self.x)
		if self.y != 0.0:
			GDScriptUtils.encode_tag(buffer, 5, 1)
			GDScriptUtils.encode_double(buffer, self.y)
		if self.coins != 0:
			GDScriptUtils.encode_tag(buffer, 6, 3)
			GDScriptUtils.encode_varint(buffer, self.coins)
		if self.mass != 0.0:
			GDScriptUtils.encode_tag(buffer, 7, 1)
			GDScriptUtils.encode_double(buffer, self.mass)
		if self.appearance != "":
			GDScriptUtils.encode_tag(buffer, 8, 9)
			GDScriptUtils.encode_string(buffer, self.appearance)
		return buffer
 
	func ParseFromBytes(data: PackedByteArray) -> int:
		var size = data.size()
		var pos = 0
 
		while pos < size:
			var tag = GDScriptUtils.decode_tag(data, pos)
			var field_number = tag[GDScriptUtils.VALUE_KEY]
			pos += tag[GDScriptUtils.SIZE_KEY]
 
			match field_number:
				1:
					var field_value = GDScriptUtils.decode_string(data, pos, self)
					self.id = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				2:
					var field_value = GDScriptUtils.decode_string(data, pos, self)
					self.username = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				3:
					var field_value = GDScriptUtils.decode_string(data, pos, self)
					self.opcode = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				4:
					var field_value = GDScriptUtils.decode_double(data, pos, self)
					self.x = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				5:
					var field_value = GDScriptUtils.decode_double(data, pos, self)
					self.y = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				6:
					var field_value = GDScriptUtils.decode_varint(data, pos, self)
					self.coins = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				7:
					var field_value = GDScriptUtils.decode_double(data, pos, self)
					self.mass = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				8:
					var field_value = GDScriptUtils.decode_string(data, pos, self)
					self.appearance = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				_:
					pass

		return pos

	func SerializeToDictionary() -> Dictionary:
		var dict = {}
		dict["id"] = self.id
		dict["username"] = self.username
		dict["opcode"] = self.opcode
		dict["x"] = self.x
		dict["y"] = self.y
		dict["coins"] = self.coins
		dict["mass"] = self.mass
		dict["appearance"] = self.appearance
		return dict

	func ParseFromDictionary(dict: Dictionary) -> void:
		if dict == null:
			return

		if dict.has("id"):
			self.id = dict.get("id")
		if dict.has("username"):
			self.username = dict.get("username")
		if dict.has("opcode"):
			self.opcode = dict.get("opcode")
		if dict.has("x"):
			self.x = dict.get("x")
		if dict.has("y"):
			self.y = dict.get("y")
		if dict.has("coins"):
			self.coins = dict.get("coins")
		if dict.has("mass"):
			self.mass = dict.get("mass")
		if dict.has("appearance"):
			self.appearance = dict.get("appearance")

# =========================================

class InitialPayload extends Message:
	#1 : bounds
	var bounds: Bounds = null

	#2 : players
	var _players: Array[Entity] = []
	var _players_size: int = 0
	## Size of _players
	func players_size() -> int:
		return self._players_size
	## Get _players
	func players() -> Array[Entity]:
		return self._players.slice(0, self._players_size)
	## Get _players item 
	func get_players(index: int) -> Entity: # index begin from 1
		if index > 0 and index <= _players_size and index <= _players.size():
			return self._players[index - 1]
		return null
	## Add _players
	func add_players(item: Entity) -> Entity:
		if self._players_size >= 0 and self._players_size < self._players.size():
			self._players[self._players_size] = item
		else:
			self._players.append(item)
		self._players_size += 1
		return item
	## Append _players
	func append_players(item_array: Array):
		for item in item_array:
			if item is Entity:
				self.add_players(item)
	## Clean _players 
	func clear_players() -> void:
		self._players_size = 0

	#3 : pellets
	var _pellets: Array[Entity] = []
	var _pellets_size: int = 0
	## Size of _pellets
	func pellets_size() -> int:
		return self._pellets_size
	## Get _pellets
	func pellets() -> Array[Entity]:
		return self._pellets.slice(0, self._pellets_size)
	## Get _pellets item 
	func get_pellets(index: int) -> Entity: # index begin from 1
		if index > 0 and index <= _pellets_size and index <= _pellets.size():
			return self._pellets[index - 1]
		return null
	## Add _pellets
	func add_pellets(item: Entity) -> Entity:
		if self._pellets_size >= 0 and self._pellets_size < self._pellets.size():
			self._pellets[self._pellets_size] = item
		else:
			self._pellets.append(item)
		self._pellets_size += 1
		return item
	## Append _pellets
	func append_pellets(item_array: Array):
		for item in item_array:
			if item is Entity:
				self.add_pellets(item)
	## Clean _pellets 
	func clear_pellets() -> void:
		self._pellets_size = 0

	#4 : powerups
	var _powerups: Array[InitialPayload.Powerup] = []
	var _powerups_size: int = 0
	## Size of _powerups
	func powerups_size() -> int:
		return self._powerups_size
	## Get _powerups
	func powerups() -> Array[InitialPayload.Powerup]:
		return self._powerups.slice(0, self._powerups_size)
	## Get _powerups item 
	func get_powerups(index: int) -> InitialPayload.Powerup: # index begin from 1
		if index > 0 and index <= _powerups_size and index <= _powerups.size():
			return self._powerups[index - 1]
		return null
	## Add _powerups
	func add_powerups(item: InitialPayload.Powerup) -> InitialPayload.Powerup:
		if self._powerups_size >= 0 and self._powerups_size < self._powerups.size():
			self._powerups[self._powerups_size] = item
		else:
			self._powerups.append(item)
		self._powerups_size += 1
		return item
	## Append _powerups
	func append_powerups(item_array: Array):
		for item in item_array:
			if item is InitialPayload.Powerup:
				self.add_powerups(item)
	## Clean _powerups 
	func clear_powerups() -> void:
		self._powerups_size = 0

	#5 : remaining_sec
	var remaining_sec: int = 0

	class Powerup extends Message:
		#1 : id
		var id: String = ""

		#2 : name
		var name: String = ""

		#3 : quantity
		var quantity: int = 0


		## Init message field values to default value
		func Init() -> void:
			self.id = ""
			self.name = ""
			self.quantity = 0

		## Create a new message instance
		## Returns: Message - New message instance
		func New() -> Message:
			var msg = Powerup.new()
			return msg

		## Message ProtoName
		## Returns: String - ProtoName
		func ProtoName() -> String:
			return "cashio.ws.Powerup"

		func MergeFrom(other : Message) -> void:
			if other is Powerup:
				self.id += other.id
				self.name += other.name
				self.quantity += other.quantity
 
		func SerializeToBytes(buffer: PackedByteArray = PackedByteArray()) -> PackedByteArray:
			if self.id != "":
				GDScriptUtils.encode_tag(buffer, 1, 9)
				GDScriptUtils.encode_string(buffer, self.id)
			if self.name != "":
				GDScriptUtils.encode_tag(buffer, 2, 9)
				GDScriptUtils.encode_string(buffer, self.name)
			if self.quantity != 0:
				GDScriptUtils.encode_tag(buffer, 3, 3)
				GDScriptUtils.encode_varint(buffer, self.quantity)
			return buffer
 
		func ParseFromBytes(data: PackedByteArray) -> int:
			var size = data.size()
			var pos = 0
 
			while pos < size:
				var tag = GDScriptUtils.decode_tag(data, pos)
				var field_number = tag[GDScriptUtils.VALUE_KEY]
				pos += tag[GDScriptUtils.SIZE_KEY]
 
				match field_number:
					1:
						var field_value = GDScriptUtils.decode_string(data, pos, self)
						self.id = field_value[GDScriptUtils.VALUE_KEY]
						pos += field_value[GDScriptUtils.SIZE_KEY]
					2:
						var field_value = GDScriptUtils.decode_string(data, pos, self)
						self.name = field_value[GDScriptUtils.VALUE_KEY]
						pos += field_value[GDScriptUtils.SIZE_KEY]
					3:
						var field_value = GDScriptUtils.decode_varint(data, pos, self)
						self.quantity = field_value[GDScriptUtils.VALUE_KEY]
						pos += field_value[GDScriptUtils.SIZE_KEY]
					_:
						pass

			return pos

		func SerializeToDictionary() -> Dictionary:
			var dict = {}
			dict["id"] = self.id
			dict["name"] = self.name
			dict["quantity"] = self.quantity
			return dict

		func ParseFromDictionary(dict: Dictionary) -> void:
			if dict == null:
				return

			if dict.has("id"):
				self.id = dict.get("id")
			if dict.has("name"):
				self.name = dict.get("name")
			if dict.has("quantity"):
				self.quantity = dict.get("quantity")


	## Init message field values to default value
	func Init() -> void:
		if self.bounds != null:			self.bounds.clear()
		self.clear_players
		self.clear_pellets
		self.clear_powerups
		self.remaining_sec = 0

	## Create a new message instance
	## Returns: Message - New message instance
	func New() -> Message:
		var msg = InitialPayload.new()
		return msg

	## Message ProtoName
	## Returns: String - ProtoName
	func ProtoName() -> String:
		return "cashio.ws.InitialPayload"

	func MergeFrom(other : Message) -> void:
		if other is InitialPayload:
			if other.bounds != null:
				if self.bounds == null:
					self.bounds = Bounds.new()
				self.bounds.MergeFrom(other.bounds)
			else:
				self.bounds = null
			self._players = self._players.slice(0, _players_size)
			self._players.append_array(other._players.slice(0, other._players_size))
			self._players_size += other._players_size
			self._pellets = self._pellets.slice(0, _pellets_size)
			self._pellets.append_array(other._pellets.slice(0, other._pellets_size))
			self._pellets_size += other._pellets_size
			self._powerups = self._powerups.slice(0, _powerups_size)
			self._powerups.append_array(other._powerups.slice(0, other._powerups_size))
			self._powerups_size += other._powerups_size
			self.remaining_sec += other.remaining_sec
 
	func SerializeToBytes(buffer: PackedByteArray = PackedByteArray()) -> PackedByteArray:
		if self.bounds != null:
			GDScriptUtils.encode_tag(buffer, 1, 11)
			GDScriptUtils.encode_message(buffer, self.bounds)
		for item in self._players:
			GDScriptUtils.encode_tag(buffer, 2, 11)
			GDScriptUtils.encode_message(buffer, item)
		for item in self._pellets:
			GDScriptUtils.encode_tag(buffer, 3, 11)
			GDScriptUtils.encode_message(buffer, item)
		for item in self._powerups:
			GDScriptUtils.encode_tag(buffer, 4, 11)
			GDScriptUtils.encode_message(buffer, item)
		if self.remaining_sec != 0:
			GDScriptUtils.encode_tag(buffer, 5, 3)
			GDScriptUtils.encode_varint(buffer, self.remaining_sec)
		return buffer
 
	func ParseFromBytes(data: PackedByteArray) -> int:
		var size = data.size()
		var pos = 0
 
		while pos < size:
			var tag = GDScriptUtils.decode_tag(data, pos)
			var field_number = tag[GDScriptUtils.VALUE_KEY]
			pos += tag[GDScriptUtils.SIZE_KEY]
 
			match field_number:
				1:
					if self.bounds == null:
						self.bounds = Bounds.new()
					self.bounds.Init()
					var field_value = GDScriptUtils.decode_message(data, pos, self.bounds)
					self.bounds = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				2:
					var sub__players = Entity.new()
					var field_value = GDScriptUtils.decode_message(data, pos, sub__players)
					self.add_players(field_value[GDScriptUtils.VALUE_KEY])
					pos += field_value[GDScriptUtils.SIZE_KEY]
				3:
					var sub__pellets = Entity.new()
					var field_value = GDScriptUtils.decode_message(data, pos, sub__pellets)
					self.add_pellets(field_value[GDScriptUtils.VALUE_KEY])
					pos += field_value[GDScriptUtils.SIZE_KEY]
				4:
					var sub__powerups = InitialPayload.Powerup.new()
					var field_value = GDScriptUtils.decode_message(data, pos, sub__powerups)
					self.add_powerups(field_value[GDScriptUtils.VALUE_KEY])
					pos += field_value[GDScriptUtils.SIZE_KEY]
				5:
					var field_value = GDScriptUtils.decode_varint(data, pos, self)
					self.remaining_sec = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				_:
					pass

		return pos

	func SerializeToDictionary() -> Dictionary:
		var dict = {}
		if self.bounds != null:
			dict["bounds"] = self.bounds.SerializeToDictionary()
		dict["players"] = []
		for index in range(1, self._players_size + 1):
			var item = self.get_players(index)
			dict["players"].append(item.SerializeToDictionary())
		dict["pellets"] = []
		for index in range(1, self._pellets_size + 1):
			var item = self.get_pellets(index)
			dict["pellets"].append(item.SerializeToDictionary())
		dict["powerups"] = []
		for index in range(1, self._powerups_size + 1):
			var item = self.get_powerups(index)
			dict["powerups"].append(item.SerializeToDictionary())
		dict["remaining_sec"] = self.remaining_sec
		return dict

	func ParseFromDictionary(dict: Dictionary) -> void:
		if dict == null:
			return

		if dict.has("bounds"):
			if self.bounds == null:
				self.bounds = Bounds.new()
			self.bounds.Init()
			self.bounds.ParseFromDictionary(dict.get("bounds"))
		else:
			self.bounds = null
		self.clear_players()
		if dict.has("players"):
			var list = dict["players"]
			for item in list:
				var item_msg = Entity.new()
				item_msg.ParseFromDictionary(item)
				self.add_players(item_msg)
		self.clear_pellets()
		if dict.has("pellets"):
			var list = dict["pellets"]
			for item in list:
				var item_msg = Entity.new()
				item_msg.ParseFromDictionary(item)
				self.add_pellets(item_msg)
		self.clear_powerups()
		if dict.has("powerups"):
			var list = dict["powerups"]
			for item in list:
				var item_msg = InitialPayload.Powerup.new()
				item_msg.ParseFromDictionary(item)
				self.add_powerups(item_msg)
		if dict.has("remaining_sec"):
			self.remaining_sec = dict.get("remaining_sec")

# =========================================

class SnapshotPayload extends Message:
	#1 : bounds
	var bounds: Bounds = null

	#2 : updated_players
	var _updated_players: Array[SnapshotPayload.Player] = []
	var _updated_players_size: int = 0
	## Size of _updated_players
	func updated_players_size() -> int:
		return self._updated_players_size
	## Get _updated_players
	func updated_players() -> Array[SnapshotPayload.Player]:
		return self._updated_players.slice(0, self._updated_players_size)
	## Get _updated_players item 
	func get_updated_players(index: int) -> SnapshotPayload.Player: # index begin from 1
		if index > 0 and index <= _updated_players_size and index <= _updated_players.size():
			return self._updated_players[index - 1]
		return null
	## Add _updated_players
	func add_updated_players(item: SnapshotPayload.Player) -> SnapshotPayload.Player:
		if self._updated_players_size >= 0 and self._updated_players_size < self._updated_players.size():
			self._updated_players[self._updated_players_size] = item
		else:
			self._updated_players.append(item)
		self._updated_players_size += 1
		return item
	## Append _updated_players
	func append_updated_players(item_array: Array):
		for item in item_array:
			if item is SnapshotPayload.Player:
				self.add_updated_players(item)
	## Clean _updated_players 
	func clear_updated_players() -> void:
		self._updated_players_size = 0

	#3 : spawned_players
	var _spawned_players: Array[Entity] = []
	var _spawned_players_size: int = 0
	## Size of _spawned_players
	func spawned_players_size() -> int:
		return self._spawned_players_size
	## Get _spawned_players
	func spawned_players() -> Array[Entity]:
		return self._spawned_players.slice(0, self._spawned_players_size)
	## Get _spawned_players item 
	func get_spawned_players(index: int) -> Entity: # index begin from 1
		if index > 0 and index <= _spawned_players_size and index <= _spawned_players.size():
			return self._spawned_players[index - 1]
		return null
	## Add _spawned_players
	func add_spawned_players(item: Entity) -> Entity:
		if self._spawned_players_size >= 0 and self._spawned_players_size < self._spawned_players.size():
			self._spawned_players[self._spawned_players_size] = item
		else:
			self._spawned_players.append(item)
		self._spawned_players_size += 1
		return item
	## Append _spawned_players
	func append_spawned_players(item_array: Array):
		for item in item_array:
			if item is Entity:
				self.add_spawned_players(item)
	## Clean _spawned_players 
	func clear_spawned_players() -> void:
		self._spawned_players_size = 0

	#4 : removed_players
	var _removed_players: Array[String] = []
	var _removed_players_size: int = 0
	## Size of _removed_players
	func removed_players_size() -> int:
		return self._removed_players_size
	## Get _removed_players
	func removed_players() -> Array[String]:
		return self._removed_players.slice(0, self._removed_players_size)
	## Get _removed_players item 
	func get_removed_players(index: int) -> String: # index begin from 1
		if index > 0 and index <= _removed_players_size and index <= _removed_players.size():
			return self._removed_players[index - 1]
		return ""
	## Add _removed_players
	func add_removed_players(item: String) -> String:
		if self._removed_players_size >= 0 and self._removed_players_size < self._removed_players.size():
			self._removed_players[self._removed_players_size] = item
		else:
			self._removed_players.append(item)
		self._removed_players_size += 1
		return item
	## Append _removed_players
	func append_removed_players(item_array: Array):
		for item in item_array:
			if item is String:
				self.add_removed_players(item)
	## Clean _removed_players 
	func clear_removed_players() -> void:
		self._removed_players_size = 0

	#5 : spawned_pellets
	var _spawned_pellets: Array[Entity] = []
	var _spawned_pellets_size: int = 0
	## Size of _spawned_pellets
	func spawned_pellets_size() -> int:
		return self._spawned_pellets_size
	## Get _spawned_pellets
	func spawned_pellets() -> Array[Entity]:
		return self._spawned_pellets.slice(0, self._spawned_pellets_size)
	## Get _spawned_pellets item 
	func get_spawned_pellets(index: int) -> Entity: # index begin from 1
		if index > 0 and index <= _spawned_pellets_size and index <= _spawned_pellets.size():
			return self._spawned_pellets[index - 1]
		return null
	## Add _spawned_pellets
	func add_spawned_pellets(item: Entity) -> Entity:
		if self._spawned_pellets_size >= 0 and self._spawned_pellets_size < self._spawned_pellets.size():
			self._spawned_pellets[self._spawned_pellets_size] = item
		else:
			self._spawned_pellets.append(item)
		self._spawned_pellets_size += 1
		return item
	## Append _spawned_pellets
	func append_spawned_pellets(item_array: Array):
		for item in item_array:
			if item is Entity:
				self.add_spawned_pellets(item)
	## Clean _spawned_pellets 
	func clear_spawned_pellets() -> void:
		self._spawned_pellets_size = 0

	#6 : removed_pellets
	var _removed_pellets: Array[String] = []
	var _removed_pellets_size: int = 0
	## Size of _removed_pellets
	func removed_pellets_size() -> int:
		return self._removed_pellets_size
	## Get _removed_pellets
	func removed_pellets() -> Array[String]:
		return self._removed_pellets.slice(0, self._removed_pellets_size)
	## Get _removed_pellets item 
	func get_removed_pellets(index: int) -> String: # index begin from 1
		if index > 0 and index <= _removed_pellets_size and index <= _removed_pellets.size():
			return self._removed_pellets[index - 1]
		return ""
	## Add _removed_pellets
	func add_removed_pellets(item: String) -> String:
		if self._removed_pellets_size >= 0 and self._removed_pellets_size < self._removed_pellets.size():
			self._removed_pellets[self._removed_pellets_size] = item
		else:
			self._removed_pellets.append(item)
		self._removed_pellets_size += 1
		return item
	## Append _removed_pellets
	func append_removed_pellets(item_array: Array):
		for item in item_array:
			if item is String:
				self.add_removed_pellets(item)
	## Clean _removed_pellets 
	func clear_removed_pellets() -> void:
		self._removed_pellets_size = 0

	class Player extends Message:
		#1 : id
		var id: String = ""

		#2 : x
		var x: float = 0.0

		#3 : y
		var y: float = 0.0

		#4 : coins
		var coins: int = 0

		#5 : mass
		var mass: float = 0.0


		## Init message field values to default value
		func Init() -> void:
			self.id = ""
			self.x = 0.0
			self.y = 0.0
			self.coins = 0
			self.mass = 0.0

		## Create a new message instance
		## Returns: Message - New message instance
		func New() -> Message:
			var msg = Player.new()
			return msg

		## Message ProtoName
		## Returns: String - ProtoName
		func ProtoName() -> String:
			return "cashio.ws.Player"

		func MergeFrom(other : Message) -> void:
			if other is Player:
				self.id += other.id
				self.x += other.x
				self.y += other.y
				self.coins += other.coins
				self.mass += other.mass
 
		func SerializeToBytes(buffer: PackedByteArray = PackedByteArray()) -> PackedByteArray:
			if self.id != "":
				GDScriptUtils.encode_tag(buffer, 1, 9)
				GDScriptUtils.encode_string(buffer, self.id)
			if self.x != 0.0:
				GDScriptUtils.encode_tag(buffer, 2, 1)
				GDScriptUtils.encode_double(buffer, self.x)
			if self.y != 0.0:
				GDScriptUtils.encode_tag(buffer, 3, 1)
				GDScriptUtils.encode_double(buffer, self.y)
			if self.coins != 0:
				GDScriptUtils.encode_tag(buffer, 4, 3)
				GDScriptUtils.encode_varint(buffer, self.coins)
			if self.mass != 0.0:
				GDScriptUtils.encode_tag(buffer, 5, 1)
				GDScriptUtils.encode_double(buffer, self.mass)
			return buffer
 
		func ParseFromBytes(data: PackedByteArray) -> int:
			var size = data.size()
			var pos = 0
 
			while pos < size:
				var tag = GDScriptUtils.decode_tag(data, pos)
				var field_number = tag[GDScriptUtils.VALUE_KEY]
				pos += tag[GDScriptUtils.SIZE_KEY]
 
				match field_number:
					1:
						var field_value = GDScriptUtils.decode_string(data, pos, self)
						self.id = field_value[GDScriptUtils.VALUE_KEY]
						pos += field_value[GDScriptUtils.SIZE_KEY]
					2:
						var field_value = GDScriptUtils.decode_double(data, pos, self)
						self.x = field_value[GDScriptUtils.VALUE_KEY]
						pos += field_value[GDScriptUtils.SIZE_KEY]
					3:
						var field_value = GDScriptUtils.decode_double(data, pos, self)
						self.y = field_value[GDScriptUtils.VALUE_KEY]
						pos += field_value[GDScriptUtils.SIZE_KEY]
					4:
						var field_value = GDScriptUtils.decode_varint(data, pos, self)
						self.coins = field_value[GDScriptUtils.VALUE_KEY]
						pos += field_value[GDScriptUtils.SIZE_KEY]
					5:
						var field_value = GDScriptUtils.decode_double(data, pos, self)
						self.mass = field_value[GDScriptUtils.VALUE_KEY]
						pos += field_value[GDScriptUtils.SIZE_KEY]
					_:
						pass

			return pos

		func SerializeToDictionary() -> Dictionary:
			var dict = {}
			dict["id"] = self.id
			dict["x"] = self.x
			dict["y"] = self.y
			dict["coins"] = self.coins
			dict["mass"] = self.mass
			return dict

		func ParseFromDictionary(dict: Dictionary) -> void:
			if dict == null:
				return

			if dict.has("id"):
				self.id = dict.get("id")
			if dict.has("x"):
				self.x = dict.get("x")
			if dict.has("y"):
				self.y = dict.get("y")
			if dict.has("coins"):
				self.coins = dict.get("coins")
			if dict.has("mass"):
				self.mass = dict.get("mass")


	## Init message field values to default value
	func Init() -> void:
		if self.bounds != null:			self.bounds.clear()
		self.clear_updated_players
		self.clear_spawned_players
		self.clear_removed_players
		self.clear_spawned_pellets
		self.clear_removed_pellets

	## Create a new message instance
	## Returns: Message - New message instance
	func New() -> Message:
		var msg = SnapshotPayload.new()
		return msg

	## Message ProtoName
	## Returns: String - ProtoName
	func ProtoName() -> String:
		return "cashio.ws.SnapshotPayload"

	func MergeFrom(other : Message) -> void:
		if other is SnapshotPayload:
			if other.bounds != null:
				if self.bounds == null:
					self.bounds = Bounds.new()
				self.bounds.MergeFrom(other.bounds)
			else:
				self.bounds = null
			self._updated_players = self._updated_players.slice(0, _updated_players_size)
			self._updated_players.append_array(other._updated_players.slice(0, other._updated_players_size))
			self._updated_players_size += other._updated_players_size
			self._spawned_players = self._spawned_players.slice(0, _spawned_players_size)
			self._spawned_players.append_array(other._spawned_players.slice(0, other._spawned_players_size))
			self._spawned_players_size += other._spawned_players_size
			self._removed_players = self._removed_players.slice(0, _removed_players_size)
			self._removed_players.append_array(other._removed_players.slice(0, other._removed_players_size))
			self._removed_players_size += other._removed_players_size
			self._spawned_pellets = self._spawned_pellets.slice(0, _spawned_pellets_size)
			self._spawned_pellets.append_array(other._spawned_pellets.slice(0, other._spawned_pellets_size))
			self._spawned_pellets_size += other._spawned_pellets_size
			self._removed_pellets = self._removed_pellets.slice(0, _removed_pellets_size)
			self._removed_pellets.append_array(other._removed_pellets.slice(0, other._removed_pellets_size))
			self._removed_pellets_size += other._removed_pellets_size
 
	func SerializeToBytes(buffer: PackedByteArray = PackedByteArray()) -> PackedByteArray:
		if self.bounds != null:
			GDScriptUtils.encode_tag(buffer, 1, 11)
			GDScriptUtils.encode_message(buffer, self.bounds)
		for item in self._updated_players:
			GDScriptUtils.encode_tag(buffer, 2, 11)
			GDScriptUtils.encode_message(buffer, item)
		for item in self._spawned_players:
			GDScriptUtils.encode_tag(buffer, 3, 11)
			GDScriptUtils.encode_message(buffer, item)
		for item in self._removed_players:
			GDScriptUtils.encode_tag(buffer, 4, 9)
			GDScriptUtils.encode_string(buffer, item)
		for item in self._spawned_pellets:
			GDScriptUtils.encode_tag(buffer, 5, 11)
			GDScriptUtils.encode_message(buffer, item)
		for item in self._removed_pellets:
			GDScriptUtils.encode_tag(buffer, 6, 9)
			GDScriptUtils.encode_string(buffer, item)
		return buffer
 
	func ParseFromBytes(data: PackedByteArray) -> int:
		var size = data.size()
		var pos = 0
 
		while pos < size:
			var tag = GDScriptUtils.decode_tag(data, pos)
			var field_number = tag[GDScriptUtils.VALUE_KEY]
			pos += tag[GDScriptUtils.SIZE_KEY]
 
			match field_number:
				1:
					if self.bounds == null:
						self.bounds = Bounds.new()
					self.bounds.Init()
					var field_value = GDScriptUtils.decode_message(data, pos, self.bounds)
					self.bounds = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				2:
					var sub__updated_players = SnapshotPayload.Player.new()
					var field_value = GDScriptUtils.decode_message(data, pos, sub__updated_players)
					self.add_updated_players(field_value[GDScriptUtils.VALUE_KEY])
					pos += field_value[GDScriptUtils.SIZE_KEY]
				3:
					var sub__spawned_players = Entity.new()
					var field_value = GDScriptUtils.decode_message(data, pos, sub__spawned_players)
					self.add_spawned_players(field_value[GDScriptUtils.VALUE_KEY])
					pos += field_value[GDScriptUtils.SIZE_KEY]
				4:
					var field_value = GDScriptUtils.decode_string(data, pos, self)
					self.add_removed_players(field_value[GDScriptUtils.VALUE_KEY])
					pos += field_value[GDScriptUtils.SIZE_KEY]
				5:
					var sub__spawned_pellets = Entity.new()
					var field_value = GDScriptUtils.decode_message(data, pos, sub__spawned_pellets)
					self.add_spawned_pellets(field_value[GDScriptUtils.VALUE_KEY])
					pos += field_value[GDScriptUtils.SIZE_KEY]
				6:
					var field_value = GDScriptUtils.decode_string(data, pos, self)
					self.add_removed_pellets(field_value[GDScriptUtils.VALUE_KEY])
					pos += field_value[GDScriptUtils.SIZE_KEY]
				_:
					pass

		return pos

	func SerializeToDictionary() -> Dictionary:
		var dict = {}
		if self.bounds != null:
			dict["bounds"] = self.bounds.SerializeToDictionary()
		dict["updated_players"] = []
		for index in range(1, self._updated_players_size + 1):
			var item = self.get_updated_players(index)
			dict["updated_players"].append(item.SerializeToDictionary())
		dict["spawned_players"] = []
		for index in range(1, self._spawned_players_size + 1):
			var item = self.get_spawned_players(index)
			dict["spawned_players"].append(item.SerializeToDictionary())
		dict["removed_players"] = self._removed_players
		dict["spawned_pellets"] = []
		for index in range(1, self._spawned_pellets_size + 1):
			var item = self.get_spawned_pellets(index)
			dict["spawned_pellets"].append(item.SerializeToDictionary())
		dict["removed_pellets"] = self._removed_pellets
		return dict

	func ParseFromDictionary(dict: Dictionary) -> void:
		if dict == null:
			return

		if dict.has("bounds"):
			if self.bounds == null:
				self.bounds = Bounds.new()
			self.bounds.Init()
			self.bounds.ParseFromDictionary(dict.get("bounds"))
		else:
			self.bounds = null
		self.clear_updated_players()
		if dict.has("updated_players"):
			var list = dict["updated_players"]
			for item in list:
				var item_msg = SnapshotPayload.Player.new()
				item_msg.ParseFromDictionary(item)
				self.add_updated_players(item_msg)
		self.clear_spawned_players()
		if dict.has("spawned_players"):
			var list = dict["spawned_players"]
			for item in list:
				var item_msg = Entity.new()
				item_msg.ParseFromDictionary(item)
				self.add_spawned_players(item_msg)
		self.clear_removed_players()
		if dict.has("removed_players"):
			var list = dict["removed_players"]
			for item in list:
				self.add_removed_players(item)
		self.clear_spawned_pellets()
		if dict.has("spawned_pellets"):
			var list = dict["spawned_pellets"]
			for item in list:
				var item_msg = Entity.new()
				item_msg.ParseFromDictionary(item)
				self.add_spawned_pellets(item_msg)
		self.clear_removed_pellets()
		if dict.has("removed_pellets"):
			var list = dict["removed_pellets"]
			for item in list:
				self.add_removed_pellets(item)

# =========================================

class Envelope extends Message:
	#1 : topic
	var topic: Topic = 0

	#2 : room_id
	var room_id: String = ""

	#3 : rooms
	var rooms: Rooms = null

	#4 : error_body
	var error_body: ErrorBody = null

	#5 : initial_payload
	var initial_payload: InitialPayload = null

	#6 : number_body
	var number_body: NumberBody = null

	#7 : powerup_body
	var powerup_body: PowerupBody = null

	#8 : snapshot_payload
	var snapshot_payload: SnapshotPayload = null

	#9 : input_body
	var input_body: InputBody = null

	#10 : create_deposit_body
	var create_deposit_body: CreateDepositBody = null

	#11 : create_withdrawal_body
	var create_withdrawal_body: CreateWithdrawalBody = null

	#12 : user_payload
	var user_payload: UserPayload = null

	#13 : shop_catalog
	var shop_catalog: ShopCatalog = null

	#14 : get_me_body
	var get_me_body: GetMeBody = null

	#15 : set_avatar_body
	var set_avatar_body: SetAvatarBody = null

	#16 : deposit_created_body
	var deposit_created_body: DepositCreatedBody = null

	#17 : buy_catalog_item_body
	var buy_catalog_item_body: BuyCatalogItemBody = null

	#18 : string_body
	var string_body: StringBody = null

	#19 : withdrawal_account_status_body
	var withdrawal_account_status_body: WithdrawalAccountStatusBody = null


	## Init message field values to default value
	func Init() -> void:
		self.topic = 0
		self.room_id = ""
		if self.rooms != null:			self.rooms.clear()
		if self.error_body != null:			self.error_body.clear()
		if self.initial_payload != null:			self.initial_payload.clear()
		if self.number_body != null:			self.number_body.clear()
		if self.powerup_body != null:			self.powerup_body.clear()
		if self.snapshot_payload != null:			self.snapshot_payload.clear()
		if self.input_body != null:			self.input_body.clear()
		if self.create_deposit_body != null:			self.create_deposit_body.clear()
		if self.create_withdrawal_body != null:			self.create_withdrawal_body.clear()
		if self.user_payload != null:			self.user_payload.clear()
		if self.shop_catalog != null:			self.shop_catalog.clear()
		if self.get_me_body != null:			self.get_me_body.clear()
		if self.set_avatar_body != null:			self.set_avatar_body.clear()
		if self.deposit_created_body != null:			self.deposit_created_body.clear()
		if self.buy_catalog_item_body != null:			self.buy_catalog_item_body.clear()
		if self.string_body != null:			self.string_body.clear()
		if self.withdrawal_account_status_body != null:			self.withdrawal_account_status_body.clear()

	## Create a new message instance
	## Returns: Message - New message instance
	func New() -> Message:
		var msg = Envelope.new()
		return msg

	## Message ProtoName
	## Returns: String - ProtoName
	func ProtoName() -> String:
		return "cashio.ws.Envelope"

	func MergeFrom(other : Message) -> void:
		if other is Envelope:
			self.topic = other.topic
			self.room_id += other.room_id
			if other.rooms != null:
				if self.rooms == null:
					self.rooms = Rooms.new()
				self.rooms.MergeFrom(other.rooms)
			else:
				self.rooms = null
			if other.error_body != null:
				if self.error_body == null:
					self.error_body = ErrorBody.new()
				self.error_body.MergeFrom(other.error_body)
			else:
				self.error_body = null
			if other.initial_payload != null:
				if self.initial_payload == null:
					self.initial_payload = InitialPayload.new()
				self.initial_payload.MergeFrom(other.initial_payload)
			else:
				self.initial_payload = null
			if other.number_body != null:
				if self.number_body == null:
					self.number_body = NumberBody.new()
				self.number_body.MergeFrom(other.number_body)
			else:
				self.number_body = null
			if other.powerup_body != null:
				if self.powerup_body == null:
					self.powerup_body = PowerupBody.new()
				self.powerup_body.MergeFrom(other.powerup_body)
			else:
				self.powerup_body = null
			if other.snapshot_payload != null:
				if self.snapshot_payload == null:
					self.snapshot_payload = SnapshotPayload.new()
				self.snapshot_payload.MergeFrom(other.snapshot_payload)
			else:
				self.snapshot_payload = null
			if other.input_body != null:
				if self.input_body == null:
					self.input_body = InputBody.new()
				self.input_body.MergeFrom(other.input_body)
			else:
				self.input_body = null
			if other.create_deposit_body != null:
				if self.create_deposit_body == null:
					self.create_deposit_body = CreateDepositBody.new()
				self.create_deposit_body.MergeFrom(other.create_deposit_body)
			else:
				self.create_deposit_body = null
			if other.create_withdrawal_body != null:
				if self.create_withdrawal_body == null:
					self.create_withdrawal_body = CreateWithdrawalBody.new()
				self.create_withdrawal_body.MergeFrom(other.create_withdrawal_body)
			else:
				self.create_withdrawal_body = null
			if other.user_payload != null:
				if self.user_payload == null:
					self.user_payload = UserPayload.new()
				self.user_payload.MergeFrom(other.user_payload)
			else:
				self.user_payload = null
			if other.shop_catalog != null:
				if self.shop_catalog == null:
					self.shop_catalog = ShopCatalog.new()
				self.shop_catalog.MergeFrom(other.shop_catalog)
			else:
				self.shop_catalog = null
			if other.get_me_body != null:
				if self.get_me_body == null:
					self.get_me_body = GetMeBody.new()
				self.get_me_body.MergeFrom(other.get_me_body)
			else:
				self.get_me_body = null
			if other.set_avatar_body != null:
				if self.set_avatar_body == null:
					self.set_avatar_body = SetAvatarBody.new()
				self.set_avatar_body.MergeFrom(other.set_avatar_body)
			else:
				self.set_avatar_body = null
			if other.deposit_created_body != null:
				if self.deposit_created_body == null:
					self.deposit_created_body = DepositCreatedBody.new()
				self.deposit_created_body.MergeFrom(other.deposit_created_body)
			else:
				self.deposit_created_body = null
			if other.buy_catalog_item_body != null:
				if self.buy_catalog_item_body == null:
					self.buy_catalog_item_body = BuyCatalogItemBody.new()
				self.buy_catalog_item_body.MergeFrom(other.buy_catalog_item_body)
			else:
				self.buy_catalog_item_body = null
			if other.string_body != null:
				if self.string_body == null:
					self.string_body = StringBody.new()
				self.string_body.MergeFrom(other.string_body)
			else:
				self.string_body = null
			if other.withdrawal_account_status_body != null:
				if self.withdrawal_account_status_body == null:
					self.withdrawal_account_status_body = WithdrawalAccountStatusBody.new()
				self.withdrawal_account_status_body.MergeFrom(other.withdrawal_account_status_body)
			else:
				self.withdrawal_account_status_body = null
 
	func SerializeToBytes(buffer: PackedByteArray = PackedByteArray()) -> PackedByteArray:
		if self.topic != 0:
			GDScriptUtils.encode_tag(buffer, 1, 14)
			GDScriptUtils.encode_varint(buffer, self.topic)
		if self.room_id != "":
			GDScriptUtils.encode_tag(buffer, 2, 9)
			GDScriptUtils.encode_string(buffer, self.room_id)
		if self.rooms != null:
			GDScriptUtils.encode_tag(buffer, 3, 11)
			GDScriptUtils.encode_message(buffer, self.rooms)
		if self.error_body != null:
			GDScriptUtils.encode_tag(buffer, 4, 11)
			GDScriptUtils.encode_message(buffer, self.error_body)
		if self.initial_payload != null:
			GDScriptUtils.encode_tag(buffer, 5, 11)
			GDScriptUtils.encode_message(buffer, self.initial_payload)
		if self.number_body != null:
			GDScriptUtils.encode_tag(buffer, 6, 11)
			GDScriptUtils.encode_message(buffer, self.number_body)
		if self.powerup_body != null:
			GDScriptUtils.encode_tag(buffer, 7, 11)
			GDScriptUtils.encode_message(buffer, self.powerup_body)
		if self.snapshot_payload != null:
			GDScriptUtils.encode_tag(buffer, 8, 11)
			GDScriptUtils.encode_message(buffer, self.snapshot_payload)
		if self.input_body != null:
			GDScriptUtils.encode_tag(buffer, 9, 11)
			GDScriptUtils.encode_message(buffer, self.input_body)
		if self.create_deposit_body != null:
			GDScriptUtils.encode_tag(buffer, 10, 11)
			GDScriptUtils.encode_message(buffer, self.create_deposit_body)
		if self.create_withdrawal_body != null:
			GDScriptUtils.encode_tag(buffer, 11, 11)
			GDScriptUtils.encode_message(buffer, self.create_withdrawal_body)
		if self.user_payload != null:
			GDScriptUtils.encode_tag(buffer, 12, 11)
			GDScriptUtils.encode_message(buffer, self.user_payload)
		if self.shop_catalog != null:
			GDScriptUtils.encode_tag(buffer, 13, 11)
			GDScriptUtils.encode_message(buffer, self.shop_catalog)
		if self.get_me_body != null:
			GDScriptUtils.encode_tag(buffer, 14, 11)
			GDScriptUtils.encode_message(buffer, self.get_me_body)
		if self.set_avatar_body != null:
			GDScriptUtils.encode_tag(buffer, 15, 11)
			GDScriptUtils.encode_message(buffer, self.set_avatar_body)
		if self.deposit_created_body != null:
			GDScriptUtils.encode_tag(buffer, 16, 11)
			GDScriptUtils.encode_message(buffer, self.deposit_created_body)
		if self.buy_catalog_item_body != null:
			GDScriptUtils.encode_tag(buffer, 17, 11)
			GDScriptUtils.encode_message(buffer, self.buy_catalog_item_body)
		if self.string_body != null:
			GDScriptUtils.encode_tag(buffer, 18, 11)
			GDScriptUtils.encode_message(buffer, self.string_body)
		if self.withdrawal_account_status_body != null:
			GDScriptUtils.encode_tag(buffer, 19, 11)
			GDScriptUtils.encode_message(buffer, self.withdrawal_account_status_body)
		return buffer
 
	func ParseFromBytes(data: PackedByteArray) -> int:
		var size = data.size()
		var pos = 0
 
		while pos < size:
			var tag = GDScriptUtils.decode_tag(data, pos)
			var field_number = tag[GDScriptUtils.VALUE_KEY]
			pos += tag[GDScriptUtils.SIZE_KEY]
 
			match field_number:
				1:
					var field_value = GDScriptUtils.decode_varint(data, pos, self)
					self.topic = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				2:
					var field_value = GDScriptUtils.decode_string(data, pos, self)
					self.room_id = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				3:
					if self.rooms == null:
						self.rooms = Rooms.new()
					self.rooms.Init()
					var field_value = GDScriptUtils.decode_message(data, pos, self.rooms)
					self.rooms = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				4:
					if self.error_body == null:
						self.error_body = ErrorBody.new()
					self.error_body.Init()
					var field_value = GDScriptUtils.decode_message(data, pos, self.error_body)
					self.error_body = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				5:
					if self.initial_payload == null:
						self.initial_payload = InitialPayload.new()
					self.initial_payload.Init()
					var field_value = GDScriptUtils.decode_message(data, pos, self.initial_payload)
					self.initial_payload = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				6:
					if self.number_body == null:
						self.number_body = NumberBody.new()
					self.number_body.Init()
					var field_value = GDScriptUtils.decode_message(data, pos, self.number_body)
					self.number_body = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				7:
					if self.powerup_body == null:
						self.powerup_body = PowerupBody.new()
					self.powerup_body.Init()
					var field_value = GDScriptUtils.decode_message(data, pos, self.powerup_body)
					self.powerup_body = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				8:
					if self.snapshot_payload == null:
						self.snapshot_payload = SnapshotPayload.new()
					self.snapshot_payload.Init()
					var field_value = GDScriptUtils.decode_message(data, pos, self.snapshot_payload)
					self.snapshot_payload = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				9:
					if self.input_body == null:
						self.input_body = InputBody.new()
					self.input_body.Init()
					var field_value = GDScriptUtils.decode_message(data, pos, self.input_body)
					self.input_body = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				10:
					if self.create_deposit_body == null:
						self.create_deposit_body = CreateDepositBody.new()
					self.create_deposit_body.Init()
					var field_value = GDScriptUtils.decode_message(data, pos, self.create_deposit_body)
					self.create_deposit_body = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				11:
					if self.create_withdrawal_body == null:
						self.create_withdrawal_body = CreateWithdrawalBody.new()
					self.create_withdrawal_body.Init()
					var field_value = GDScriptUtils.decode_message(data, pos, self.create_withdrawal_body)
					self.create_withdrawal_body = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				12:
					if self.user_payload == null:
						self.user_payload = UserPayload.new()
					self.user_payload.Init()
					var field_value = GDScriptUtils.decode_message(data, pos, self.user_payload)
					self.user_payload = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				13:
					if self.shop_catalog == null:
						self.shop_catalog = ShopCatalog.new()
					self.shop_catalog.Init()
					var field_value = GDScriptUtils.decode_message(data, pos, self.shop_catalog)
					self.shop_catalog = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				14:
					if self.get_me_body == null:
						self.get_me_body = GetMeBody.new()
					self.get_me_body.Init()
					var field_value = GDScriptUtils.decode_message(data, pos, self.get_me_body)
					self.get_me_body = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				15:
					if self.set_avatar_body == null:
						self.set_avatar_body = SetAvatarBody.new()
					self.set_avatar_body.Init()
					var field_value = GDScriptUtils.decode_message(data, pos, self.set_avatar_body)
					self.set_avatar_body = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				16:
					if self.deposit_created_body == null:
						self.deposit_created_body = DepositCreatedBody.new()
					self.deposit_created_body.Init()
					var field_value = GDScriptUtils.decode_message(data, pos, self.deposit_created_body)
					self.deposit_created_body = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				17:
					if self.buy_catalog_item_body == null:
						self.buy_catalog_item_body = BuyCatalogItemBody.new()
					self.buy_catalog_item_body.Init()
					var field_value = GDScriptUtils.decode_message(data, pos, self.buy_catalog_item_body)
					self.buy_catalog_item_body = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				18:
					if self.string_body == null:
						self.string_body = StringBody.new()
					self.string_body.Init()
					var field_value = GDScriptUtils.decode_message(data, pos, self.string_body)
					self.string_body = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				19:
					if self.withdrawal_account_status_body == null:
						self.withdrawal_account_status_body = WithdrawalAccountStatusBody.new()
					self.withdrawal_account_status_body.Init()
					var field_value = GDScriptUtils.decode_message(data, pos, self.withdrawal_account_status_body)
					self.withdrawal_account_status_body = field_value[GDScriptUtils.VALUE_KEY]
					pos += field_value[GDScriptUtils.SIZE_KEY]
				_:
					pass

		return pos

	func SerializeToDictionary() -> Dictionary:
		var dict = {}
		dict["topic"] = self.topic
		dict["room_id"] = self.room_id
		if self.rooms != null:
			dict["rooms"] = self.rooms.SerializeToDictionary()
		if self.error_body != null:
			dict["error_body"] = self.error_body.SerializeToDictionary()
		if self.initial_payload != null:
			dict["initial_payload"] = self.initial_payload.SerializeToDictionary()
		if self.number_body != null:
			dict["number_body"] = self.number_body.SerializeToDictionary()
		if self.powerup_body != null:
			dict["powerup_body"] = self.powerup_body.SerializeToDictionary()
		if self.snapshot_payload != null:
			dict["snapshot_payload"] = self.snapshot_payload.SerializeToDictionary()
		if self.input_body != null:
			dict["input_body"] = self.input_body.SerializeToDictionary()
		if self.create_deposit_body != null:
			dict["create_deposit_body"] = self.create_deposit_body.SerializeToDictionary()
		if self.create_withdrawal_body != null:
			dict["create_withdrawal_body"] = self.create_withdrawal_body.SerializeToDictionary()
		if self.user_payload != null:
			dict["user_payload"] = self.user_payload.SerializeToDictionary()
		if self.shop_catalog != null:
			dict["shop_catalog"] = self.shop_catalog.SerializeToDictionary()
		if self.get_me_body != null:
			dict["get_me_body"] = self.get_me_body.SerializeToDictionary()
		if self.set_avatar_body != null:
			dict["set_avatar_body"] = self.set_avatar_body.SerializeToDictionary()
		if self.deposit_created_body != null:
			dict["deposit_created_body"] = self.deposit_created_body.SerializeToDictionary()
		if self.buy_catalog_item_body != null:
			dict["buy_catalog_item_body"] = self.buy_catalog_item_body.SerializeToDictionary()
		if self.string_body != null:
			dict["string_body"] = self.string_body.SerializeToDictionary()
		if self.withdrawal_account_status_body != null:
			dict["withdrawal_account_status_body"] = self.withdrawal_account_status_body.SerializeToDictionary()
		return dict

	func ParseFromDictionary(dict: Dictionary) -> void:
		if dict == null:
			return

		if dict.has("topic"):
			self.topic = dict.get("topic")
		if dict.has("room_id"):
			self.room_id = dict.get("room_id")
		if dict.has("rooms"):
			if self.rooms == null:
				self.rooms = Rooms.new()
			self.rooms.Init()
			self.rooms.ParseFromDictionary(dict.get("rooms"))
		else:
			self.rooms = null
		if dict.has("error_body"):
			if self.error_body == null:
				self.error_body = ErrorBody.new()
			self.error_body.Init()
			self.error_body.ParseFromDictionary(dict.get("error_body"))
		else:
			self.error_body = null
		if dict.has("initial_payload"):
			if self.initial_payload == null:
				self.initial_payload = InitialPayload.new()
			self.initial_payload.Init()
			self.initial_payload.ParseFromDictionary(dict.get("initial_payload"))
		else:
			self.initial_payload = null
		if dict.has("number_body"):
			if self.number_body == null:
				self.number_body = NumberBody.new()
			self.number_body.Init()
			self.number_body.ParseFromDictionary(dict.get("number_body"))
		else:
			self.number_body = null
		if dict.has("powerup_body"):
			if self.powerup_body == null:
				self.powerup_body = PowerupBody.new()
			self.powerup_body.Init()
			self.powerup_body.ParseFromDictionary(dict.get("powerup_body"))
		else:
			self.powerup_body = null
		if dict.has("snapshot_payload"):
			if self.snapshot_payload == null:
				self.snapshot_payload = SnapshotPayload.new()
			self.snapshot_payload.Init()
			self.snapshot_payload.ParseFromDictionary(dict.get("snapshot_payload"))
		else:
			self.snapshot_payload = null
		if dict.has("input_body"):
			if self.input_body == null:
				self.input_body = InputBody.new()
			self.input_body.Init()
			self.input_body.ParseFromDictionary(dict.get("input_body"))
		else:
			self.input_body = null
		if dict.has("create_deposit_body"):
			if self.create_deposit_body == null:
				self.create_deposit_body = CreateDepositBody.new()
			self.create_deposit_body.Init()
			self.create_deposit_body.ParseFromDictionary(dict.get("create_deposit_body"))
		else:
			self.create_deposit_body = null
		if dict.has("create_withdrawal_body"):
			if self.create_withdrawal_body == null:
				self.create_withdrawal_body = CreateWithdrawalBody.new()
			self.create_withdrawal_body.Init()
			self.create_withdrawal_body.ParseFromDictionary(dict.get("create_withdrawal_body"))
		else:
			self.create_withdrawal_body = null
		if dict.has("user_payload"):
			if self.user_payload == null:
				self.user_payload = UserPayload.new()
			self.user_payload.Init()
			self.user_payload.ParseFromDictionary(dict.get("user_payload"))
		else:
			self.user_payload = null
		if dict.has("shop_catalog"):
			if self.shop_catalog == null:
				self.shop_catalog = ShopCatalog.new()
			self.shop_catalog.Init()
			self.shop_catalog.ParseFromDictionary(dict.get("shop_catalog"))
		else:
			self.shop_catalog = null
		if dict.has("get_me_body"):
			if self.get_me_body == null:
				self.get_me_body = GetMeBody.new()
			self.get_me_body.Init()
			self.get_me_body.ParseFromDictionary(dict.get("get_me_body"))
		else:
			self.get_me_body = null
		if dict.has("set_avatar_body"):
			if self.set_avatar_body == null:
				self.set_avatar_body = SetAvatarBody.new()
			self.set_avatar_body.Init()
			self.set_avatar_body.ParseFromDictionary(dict.get("set_avatar_body"))
		else:
			self.set_avatar_body = null
		if dict.has("deposit_created_body"):
			if self.deposit_created_body == null:
				self.deposit_created_body = DepositCreatedBody.new()
			self.deposit_created_body.Init()
			self.deposit_created_body.ParseFromDictionary(dict.get("deposit_created_body"))
		else:
			self.deposit_created_body = null
		if dict.has("buy_catalog_item_body"):
			if self.buy_catalog_item_body == null:
				self.buy_catalog_item_body = BuyCatalogItemBody.new()
			self.buy_catalog_item_body.Init()
			self.buy_catalog_item_body.ParseFromDictionary(dict.get("buy_catalog_item_body"))
		else:
			self.buy_catalog_item_body = null
		if dict.has("string_body"):
			if self.string_body == null:
				self.string_body = StringBody.new()
			self.string_body.Init()
			self.string_body.ParseFromDictionary(dict.get("string_body"))
		else:
			self.string_body = null
		if dict.has("withdrawal_account_status_body"):
			if self.withdrawal_account_status_body == null:
				self.withdrawal_account_status_body = WithdrawalAccountStatusBody.new()
			self.withdrawal_account_status_body.Init()
			self.withdrawal_account_status_body.ParseFromDictionary(dict.get("withdrawal_account_status_body"))
		else:
			self.withdrawal_account_status_body = null

# =========================================
