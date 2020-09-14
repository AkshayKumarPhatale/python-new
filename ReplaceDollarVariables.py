import re
global s
p=""
l=[]
exp_value={}
flag=False
with open(r"C:\Users\home\Desktop\py\log.txt", 'wt') as rplc:
    with open(r"C:\Users\home\Desktop\py\AFC_EDW_CLM_PARM.parm", 'rt') as parm:
        for line in parm:
            pattern1 = "^export.*,$"# starts with word 'export' and ends with ,
            pattern2 = "^\'.*\'$"  # starts with ' and ends with '
            pattern3 = "^\'.*\"$"  # starts with ' and ends with "
            pattern4 = "^,.*\"$"  # starts with , and ends with "
            pattern5 = "^,.*,$"  # starts with , and ends with ,
            pattern6 = "\',.*,$"  # starts with ' and ends with ,
            pattern7 = "^export.*\"" # starts with word 'export' and ends with "
            pattern8 = "^export.*\'$" # starts with word 'export' and ends with '

            if re.search(pattern1, line):
                # if parmline.startswith("export") and parmline.endswith(",") or  parmline.endswith("\'") or parmline.endswith("\"") :
                s = line.strip()

            elif re.search(pattern2, line):
                s = s + line.strip()

            elif re.search(pattern3, line):
                s = s + line
                l.append(s)
                rplc.write(s)

            elif re.search(pattern4, line):
                s = s + line
                l.append(s)
                rplc.write(s)
            elif re.search(pattern5, line):
                s = s + line.strip()

            elif re.search(pattern6, line):
                s = s + line.strip()

            elif line.startswith("#"):
                s = ""

            elif re.search(pattern7, line):
                s = line
                l.append(s)
                rplc.write(s)
            elif re.search(pattern8, line):
                s=line
                l.append(s)
                rplc.write(s)
            else:
                s=line
                l.append(s)
                rplc.write(s)
        for eachpair in l:
            if eachpair.startswith('export'):
                eachpair = eachpair.replace('export', '')
                key_value = eachpair.split('=')
                exp_value[f'${key_value[0].lstrip()}'] = key_value[1]
                #exp_value[key_value[0].lstrip()] = key_value[1]

#$(( )) pending
dl=[]
rl=[]
flag=False
endposition=0
dollarstartposition=0
bracketposition=0

with open(r"C:\Users\home\Desktop\py\output.txt", "rt") as fin:
    for line in fin:
        dl.append(line)
try:
    for text in dl:
        if '$' in text:
            for element in range(0, len(text)):
                if text[element] == "$":
                    flag = True
                    startposition = element

                elif flag:
                    if text[element] == ";" or text[element] == "\'" or text[element] == "." or text[element] == ")" or text[element] == "" or text[element] == " ":
                        endposition = element
                        #rl.append(text[startposition + 1:endposition])
                        #text= text.replace(text[startposition + 1:endposition],exp_value.get(text[startposition + 1:endposition]))
                        s=text[startposition:endposition]
                        print(s)
                        flag = False

        if '$((' in text:
            for element in range(0, len(text)):
                if text[element] == "$":
                    flag = True
                    startposition = element+2
        elif flag:
            if text[element] == ")":
                endposition = element
                # rl.append(text[startposition + 1:endposition])
                # text= text.replace(text[startposition + 1:endposition],exp_value.get(text[startposition + 1:endposition]))
                s = text[startposition:endposition+1]
                print(s)
                flag = False

except:
    print(s+' '+'not exists in a parm file')


#for item in rl:
#print(item)