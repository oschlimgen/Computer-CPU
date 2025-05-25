from glob import glob

from OperationEncode import encode


PROGRAM_EXTENSION = '.txt'

def main():
  programFiles = glob('*' + PROGRAM_EXTENSION, root_dir='Programs')
  if len(programFiles) == 0:
    print(f'No files with extension {PROGRAM_EXTENSION} found.')
  for fileName in programFiles:
    # Read the file
    file = open('Programs/' + fileName, 'r')
    lines = file.readlines()
    file.close()
    # Handle precompilation tasks
    lines = removeExtraLines(lines, fileName)
    if lines is None:
      return
    # Write pure machine code to a file
    machineCode = open('Programs/' + fileName.replace(PROGRAM_EXTENSION,'.asm'), 'w')
    for line in lines:
      if line == '':
        continue
      machineCode.write(line + '\n')
    machineCode.close()
    # Compile to binary
    toWrite = list()
    for i, line in enumerate(lines):
      if line == '':
        continue
      result = encode(line)
      if result.isnumeric():
        toWrite.append(result)
      else:
        print(f'Error in line {i+1} of {fileName}:')
        print(result)
        return
    print(f'{fileName} compiled successfully!')
    # Write to file on successful compile
    compiled = open('Programs/' + fileName.replace(PROGRAM_EXTENSION,'.sv'), 'w')
    programName = fileName.replace(PROGRAM_EXTENSION,'').replace(' ','_').upper()
    compiled.write('`ifndef {name}\n`define {name}\n\n'.format(name = 'PROGRAM_' + programName))
    compiled.write('parameter [31:0] INSTRUCTIONS_{}[0:{}] = {{\n'.format(programName, len(toWrite)-1))
    for i, binary in enumerate(toWrite):
      compiled.write(('' if i == 0 else ',\n') + f"  32'b{binary}")
    compiled.write('\n};\n\n`endif')
    compiled.close()
  print('Compilation complete.')


def removeExtraLines(lines : list[str], fileName : str) -> list[str]:
  newlines = [''] * len(lines)
  definitions = dict[str,str]()
  jumpPoints = dict[str,int]()
  jumpLineNum = 0
  # First pass
  for i, line in enumerate(lines):
    line = line.split('//')[0].strip().rstrip(';').replace(',',' ')
    if line == '':
      continue
    # Replace definitions
    for key, value in definitions.items():
      line = line.replace(key, value)
    # Check for lines that must be preprocessed
    if line.startswith('#define '):
      line = line.split()
      if len(line) < 3:
        print(f'Error in line {i+1} of {fileName}:')
        print('define must have two parameters')
        return
      definitions[line[1]] = ' '.join(line[2:])
    elif line.startswith('.'):
      if not line.endswith(':'):
        print(f'Error in line {i+1} of {fileName}:')
        print("Jump locations starting with '.' must end with ':'")
        return
      if line.count(' ') > 0:
        print(f'Error in line {i+1} of {fileName}:')
        print("Jump location names can't contain spaces.")
        return
      jumpPoints[line.rstrip(':')] = jumpLineNum
    else:
      newlines[i] = line
      jumpLineNum += 1
  # Second pass
  instructionCount = 0
  for i, line in enumerate(newlines):
    if line == '':
      continue
    for jumpTag, point in jumpPoints.items():
      line = line.replace(jumpTag, str(4 * (point - instructionCount)))
    newlines[i] = line
    instructionCount += 1
  return newlines



main()

