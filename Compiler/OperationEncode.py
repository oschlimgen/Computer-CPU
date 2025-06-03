import OperationDefinitions

def encode(string: str) -> str:
  inst = string.split(' ')
  inst[0] = inst[0].upper()
  op = OperationDefinitions.OPERATIONS.get(inst[0])
  if op is None:
    return 'Unrecognized Operation'
  msg = _checkArguments(inst)
  if msg is not None:
    return msg
  
  inst_numeric = [inst[0]] + list(map(_convertToNumber, inst[1:]))
  binaryInst = _createInstruction(inst_numeric)
  binaryString = format(binaryInst, '032b')
  return binaryString


def _convertToNumber(num: str) -> int:
  return int(num.lstrip('x$'), base=0)

def _createInstruction(inst: list[int]) -> int:
  op = OperationDefinitions.OPERATIONS[inst[0]]
  en = OperationDefinitions.ENCODING_TYPES[inst[0]]
  match en:
    case 'R':
      return (
        op[0] |
        inst[1] << 7 |
        op[1] << 12 |
        inst[2] << 15 |
        inst[3] << 20 |
        op[2] << 25
      )
    case 'I':
      return (
        op[0] |
        inst[1] << 7 |
        op[1] << 12 |
        inst[2] << 15 |
        inst[3] << 20
      )
    case 'S':
      return (
        op[0] |
        op[1] << 12 |
        inst[2] << 15 | # Swap parameters 1 and 2 of store operations
        inst[1] << 20 | # for a more intuitive instruction order
        (inst[3] & 0b000000011111) << 7 |
        (inst[3] & 0b111111100000) << 20
      )
    case 'B':
      return (
        op[0] |
        op[1] << 12 |
        inst[1] << 15 |
        inst[2] << 20 |
        (inst[3] & 0b0000000011110) << 7 |
        (inst[3] & 0b0011111100000) << 20 |
        (inst[3] & 0b0100000000000) >> 4 |
        (inst[3] & 0b1000000000000) << 19
      )
    case 'U':
      return (
        op[0] |
        inst[1] << 7 |
        inst[2] << 12
      )
    case 'J':
      return (
        op[0] |
        inst[1] << 7 |
        (inst[2] & 0b000000000011111111110) << 20 |
        (inst[2] & 0b000000000100000000000) << 9 |
        (inst[2] & 0b011111111000000000000) |
        (inst[2] & 0b100000000000000000000) << 11
      )
    case 'F':
      return (
        op[0] |
        inst[1] << 7 |
        op[1] << 12 |
        inst[2] << 15 |
        op[2] << 20 |
        op[3] << 24
      )
    case _:
      return op


def _checkArguments(inst: list[str]) -> str | None:
  sizes = OperationDefinitions.ARGUMENT_SIZES[inst[0]]
  if len(inst)-1 != len(sizes):
    return 'Wrong number of arguments'
  for i, size in enumerate(sizes):
    param = inst[i+1]
    if type(size) is str:
      # Parameter is a register - designated by a string for size in ARGUMENT_SIZES
      try:
        reg = int(param.lstrip('x'))
      except:
        return f'Parameter #{i+1} of {inst[0]} must be a register number'
      if reg < 0 or reg >= 32:
        return f'Parameter #{i+1}: Registers numbers must be between 0 and 31'
    else:
      # Parameter is a constant - designated by a number or object for size in ARGUMENT_SIZES
      try:
        num = int(param.lstrip('$'), base=0)
      except:
        return f'Parameter #{i+1} of {inst[0]} must be a constant number'
      if type(size) is int:
        if num < 0 or num > 2**size - 1: # Not accepting negative numbers could be an issue
          return f'Parameter #{i+1} of {inst[0]} can only be {size} bits wide'
      elif size.get('max') and size.get('min'):
        if num < -2**(size.get('max')-1) or num > 2**(size.get('max')-1)-1:
          return f'Parameter #{i+1} of {inst[0]} can only be {size.get('max')} bits wide'
        if abs(num) % 2**size.get('min') != 0:
          return f'Parameter #{i+1} of {inst[0]} must be a multiple of {2**size.get('min')}'
      else:
        raise Exception('Internal error: object in ARGUMENT_SIZES is not int or dictionary of proper form.')
  return None # Successful check



