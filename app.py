import re
global s
p=""
l=[]
storeDollar=[]
exp_value={}
flag=False
with open(r"C:\Users\home\Desktop\py\log.txt", 'wt') as rplc:
    with open(r"C:\Users\home\Desktop\py\AFC_EDW_CLM_PARM.parm", 'rt') as parm:
        for parmline in parm:
            pattern1 = "^export.*,$"
            pattern2 = "^\'.*\'$"  # starts with ' and ends with '
            pattern3 = "^\'.*\"$"  # starts with ' and ends with "
            pattern4 = "^,.*\"$"  # starts with , and ends with "
            pattern5 = "^,.*,$"  # starts with , and ends with ,
            pattern6 = "\',.*,$"  # starts with ' and ends with ,
            pattern7 = "^export.*\""
            pattern8 = "^export.*\'$"

            if re.search(pattern1, parmline):
                # if parmline.startswith("export") and parmline.endswith(",") or  parmline.endswith("\'") or parmline.endswith("\"") :
                s = parmline.strip()

            elif re.search(pattern2, parmline):
                s = s + parmline.strip()

            elif re.search(pattern3, parmline):
                s = s + parmline
                l.append(s)
                rplc.write(s)

            elif re.search(pattern4, parmline):
                s = s + parmline
                l.append(s)
                rplc.write(s)
            elif re.search(pattern5, parmline):
                s = s + parmline.strip()

            elif re.search(pattern6, parmline):
                s = s + parmline.strip()

            elif parmline.startswith("#"):
                s = ""

            elif re.search(pattern7, parmline):
                s = parmline
                l.append(s)
                rplc.write(s)
            elif re.search(pattern8, parmline):
                s=parmline
                l.append(s)
                rplc.write(s)
            else:
                s=parmline
                l.append(s)
                rplc.write(s)
        for eachpair in l:
            if eachpair.startswith('export'):
                eachpair = eachpair.replace('export', '')
                key_value = eachpair.split('=')
                exp_value[f'${key_value[0].lstrip()}'] = key_value[1]


with open(r"C:\Users\home\Desktop\py\CLINCAL_TRIMED_APID9617_MERGE.sh", "rt") as fin:
    with open(r"C:\Users\home\Desktop\py\log.txt", "wt") as fout:
        i = 0
        j = 0
        count=0
        start=0
        end=0
        for line in fin:
            count=count+1
            if line.startswith('bteq') and 'EOF' in line:
                j = 1
            elif 'EOF' in line:
                j = 0
            if not j:
                if 'EOF' not in line:
                    line = ''
            elif j==1:

                if line.startswith('#'):
                    line = ''
                elif line.startswith('/*') or line.endswith('*/') :
                    line = ''
                elif line.startswith('/*') or line.endswith('*') :
                    line = ''
                    start=count
                    print(start)
                elif line.startswith('*') or line.startswith('*/') :
                    line = ''
                    end=count
                    print(end)




                else:
                    for s in exp_value.keys():
                        if s in parmline:
                            if '$LOGON/$LOGON_ID' in line:
                                line = line.replace('$LOGON/$LOGON_ID', exp_value.get(s))

                            else:
                                line = line.replace(s, exp_value.get(s))
            fout.write(line)

exp_value = {}
