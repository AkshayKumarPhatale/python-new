import re
dl=[]
s=''
flag=False
queryPattern=re.compile(r'\bDATABASE\b|\bINSERT\b|\bINS\b|\bDELETE\b|\bDEL\b|\bUPDATE\b|\bUPD\b|\bSELECT\b|\bSELECT\b',flags=re.IGNORECASE)
with open(r"C:\Users\home\Desktop\py\CLM_BTEQ_LZ2CSA_CIA_CLM_LINE_STG_LOAD.sh", "rt") as fin:
    for line in fin:
        dl.append(line)

for eachline in dl:
    if re.search(queryPattern,eachline):
        s=eachline.strip()+" "
        flag=True
    elif flag:
        if not eachline.endswith(';'):
            s=s+eachline.strip()+" "
        elif eachline.endswith(';'):
            s=s+eachline.strip()+" "
print(s.strip())

