import re
pattern1 = "^/\*.*\*$"
pattern2 = "^\*.*\*\/$"
pattern3 = "^/\*.*\*\/$"
flag = False
l = []
with open(r"C:\Users\home\Desktop\py\CLINCAL_TRIMED_APID9617_MERGE.sh", "rt") as fin:
    for line in fin:
        if re.search(pattern1, line):
            flag = True
            line = ''
        elif flag:
            if re.search(pattern2, line):
                line = ''
                flag = False
            else:
                line = ''
        print(line)