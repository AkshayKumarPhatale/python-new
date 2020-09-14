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


            elif re.search(pattern4, line):
                s = s + line
                l.append(s)

            elif re.search(pattern5, line):
                s = s + line.strip()

            elif re.search(pattern6, line):
                s = s + line.strip()

            elif line.startswith("#"):
                s = ""

            elif re.search(pattern7, line):
                s = line
                l.append(s)

            elif re.search(pattern8, line):
                s=line
                l.append(s)

            else:
                s=line
                l.append(s)

        for eachpair in l:
            if eachpair.startswith('export'):
                eachpair = eachpair.replace('export', '')
                key_value = eachpair.split('=')
                exp_value[key_value[0].lstrip()] = key_value[1]



dl=[]
dv=[]
flag=False
endposition=0
startposition=0
with open(r"C:\Users\home\Desktop\py\CLINCAL_TRIMED_APID9617_MERGE.sh", "rt") as fin:
    for line in fin:
        dl.append(line)
for text in dl:
    if '$' in text:
        for element in range(0, len(text)):
            if text[element] == "$":
                flag = True
                startposition = element
            elif flag:
                if text[element] == ";" or text[element] == "\'" or text[element] == "." or text[element] == ")" or text[element] == "" or text[element] == " ":
                    endposition = element
                    dv.append(text[startposition + 1:endposition])
                    flag = False





