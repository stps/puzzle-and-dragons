lc3x_opcode = ['SUB', 'MULT', 'DIV', 'XOR', 'OR']
macro1 = ['NOR']
macro2 = ['XNOR']
macro3 = ['NAND']
macro4 = ['LDBSE']

def write_output(opmatch):
    outfile.write("\t")
    if (opmatch == "lc3x_opcode"):
        outfile.write("DATA2 4x"+hex(int("1000"+\
                                    bin(int(line.split()[1][1:2]))[2:].zfill(3)+\
                                    bin(int(line.split()[2][1:2]))[2:].zfill(3)+\
                                    bin(lc3x_opcode.index(line.split()[0]))[2:].zfill(3)+\
                                    bin(int(line.split()[3][1:2]))[2:].zfill(3), 2))[2:])
    elif (opmatch == "macro1"):
        outfile.write("DATA2 4x"+hex(int("1000"+\
                                    bin(int(line.split()[1][1:2]))[2:].zfill(3)+\
                                    bin(int(line.split()[2][1:2]))[2:].zfill(3)+\
                                    "100"+\
                                    bin(int(line.split()[3][1:2]))[2:].zfill(3), 2))[2:])
        outfile.write("\n\t")
        outfile.write("DATA2 4x"+hex(int("1001"+\
                                    bin(int(line.split()[1][1:2]))[2:].zfill(3)+\
                                    bin(int(line.split()[2][1:2]))[2:].zfill(3)+"111111", 2))[2:])
    elif (opmatch == "macro2"):
        outfile.write("DATA2 4x"+hex(int("1000"+\
                                    bin(int(line.split()[1][1:2]))[2:].zfill(3)+\
                                    bin(int(line.split()[2][1:2]))[2:].zfill(3)+\
                                    "011"+\
                                    bin(int(line.split()[3][1:2]))[2:].zfill(3), 2))[2:])
        outfile.write("\n\t")
        outfile.write("DATA2 4x"+hex(int("1001"+\
                                    bin(int(line.split()[1][1:2]))[2:].zfill(3)+\
                                    bin(int(line.split()[2][1:2]))[2:].zfill(3)+"111111", 2))[2:])
    elif (opmatch == "macro3"):
        outfile.write("DATA2 4x"+hex(int("0101"+\
                                    bin(int(line.split()[1][1:2]))[2:].zfill(3)+\
                                    bin(int(line.split()[2][1:2]))[2:].zfill(3)+\
                                    "000"+\
                                    bin(int(line.split()[3][1:2]))[2:].zfill(3), 2))[2:])
        
        outfile.write("\n\t")
        outfile.write("DATA2 4x"+hex(int("1001"+\
                                    bin(int(line.split()[1][1:2]))[2:].zfill(3)+\
                                    bin(int(line.split()[2][1:2]))[2:].zfill(3)+"111111", 2))[2:])
    elif (opmatch == "macro4"):
        #LDB, then sign extend the lower byte register
        outfile.write("LDB "+line.split()[1]+line.split()[2]+line.split()[3])
        outfile.write("\n\t")
        outfile.write("DATA2 4x"+hex(int("1000"+\
                                    bin(int(line.split()[1][1:2]))[2:].zfill(3)+\
                                    bin(int(line.split()[1][1:2]))[2:].zfill(3)+\
                                    "101000", 2))[2:])
    outfile.write(";")
    outfile.write(line)

while (1):
    iname = raw_input("Input file name: ")
    if (len(iname) > 4):
        if (iname[len(iname)-4:] == ".asm"):
            break

while (1):
    oname = raw_input("Output file name: ")
    if (len(oname) > 4):
        if (oname[len(oname)-4:] == ".asm"):
            break

with open(iname, 'r') as infile:
    with open(oname, 'w') as outfile:
        for line in infile:
            try:
                if line.split()[0].upper() in lc3x_opcode:
                    write_output("lc3x_opcode")
                    continue
                elif line.split()[0].upper() in macro1:
                    write_output("macro1")
                    continue
                elif line.split()[0].upper() in macro2:
                    write_output("macro2")
                    continue
                elif line.split()[0].upper() in macro3:
                    write_output("macro3")
                    continue
                elif line.split()[0].upper() in macro4:
                    write_output("macro4")
                    continue
            except IndexError:
                pass
            outfile.write(line)
