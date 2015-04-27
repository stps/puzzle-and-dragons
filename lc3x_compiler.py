lc3x_opcode = ['SUB', 'MULT', 'DIV', 'XOR', 'OR']

def write_output(opmatch):
    outfile.write("\t")
    if (opmatch == "lc3x_opcode"):
        outfile.write("DATA2 4x"+hex(int("1000"+\
                                    bin(int(line.split()[1][1:2]))[2:].zfill(3)+\
                                    bin(int(line.split()[2][1:2]))[2:].zfill(3)+\
                                    bin(lc3x_opcode.index(line.split()[0]))[2:].zfill(3)+\
                                    bin(int(line.split()[3][1:2]))[2:].zfill(3), 2))[2:])
	if (opmatch == "NOR"):
		outfile.write("DATA2 4x"+hex(int("1000"+\
                                    bin(int(line.split()[1][1:2]))[2:].zfill(3)+\
                                    bin(int(line.split()[2][1:2]))[2:].zfill(3)+\
                                    "100"+\
                                    bin(int(line.split()[3][1:2]))[2:].zfill(3), 2))[2:]+\
									"\n"+"DATA2 4x"+hex(int("1001"+\
                                    bin(int(line.split()[1][1:2]))[2:].zfill(3)+\
                                    bin(int(line.split()[2][1:2]))[2:].zfill(3)+"111111"))[2:])
	if (opmatch == "XNOR"):
		outfile.write("DATA2 4x"+hex(int("1000"+\
                                    bin(int(line.split()[1][1:2]))[2:].zfill(3)+\
                                    bin(int(line.split()[2][1:2]))[2:].zfill(3)+\
                                    "011"+\
                                    bin(int(line.split()[3][1:2]))[2:].zfill(3), 2))[2:]+\
									"\n"+"DATA2 4x"+hex(int("1001"+\
                                    bin(int(line.split()[1][1:2]))[2:].zfill(3)+\
                                    bin(int(line.split()[2][1:2]))[2:].zfill(3)+"111111"))[2:])
	if (opmatch == "NAND"):
		outfile.write("DATA2 4x"+hex(int("0101"+\
                                    bin(int(line.split()[1][1:2]))[2:].zfill(3)+\
                                    bin(int(line.split()[2][1:2]))[2:].zfill(3)+\
                                    "000"+\
                                    bin(int(line.split()[3][1:2]))[2:].zfill(3), 2))[2:]+\
									"\n"+"DATA2 4x"+hex(int("1001"+\
                                    bin(int(line.split()[1][1:2]))[2:].zfill(3)+\
                                    bin(int(line.split()[2][1:2]))[2:].zfill(3)+"111111"))[2:])
	#if (opmatch == "LDBSE"): 
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
                if line.split()[0].upper() == "NOR":
                    write_output("NOR")
                    continue
                if line.split()[0].upper() == "XNOR":
                    write_output("XNOR")
                    continue
                if line.split()[0].upper() == "NAND":
                    write_output("NAND")
                    continue
            except IndexError:
                pass
            outfile.write(line)
