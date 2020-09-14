#importing regex library
import re

# declaring variables
storeIntialFileData = []
i = 0
j = 0
count = 0
start = 0
end = 0
storeIntermediateData=[]
pattern1="^/\*.*\*$"
pattern2="^\*.*\*\/$"
pattern3="^/\*.*\*\/$"
flag=False

# logic to store all intial file data in a list
with open(r"C:\Users\home\Desktop\py\CLINCAL_TRIMED_APID9617_MERGE.sh", "rt") as fin:
    for eachline in fin:
        storeIntialFileData.append(eachline)
fin.close()

# logic to remove all comments
for line in storeIntialFileData:
    if line.startswith('bteq') and 'EOF' in line:
        j = 1

    elif 'EOF' in line:
        j = 0

    if not j:
        if 'EOF' not in line:
            line = ''.replace('','\n')

    elif j == 1:
         if line.startswith('#'):
            line = ''.replace('','\n')
         elif re.search(pattern3,line):
            line = ''.replace('','\n')
         elif re.search(pattern1, line):
            flag = True
            line = ''.replace('','\n')
         elif flag:
            if re.search(pattern2, line):
                line = ''.replace('','\n')
                flag = False
            else:
                line = ''.replace('','\n')
    storeIntermediateData.append(line)

for e in storeIntermediateData:
    print(e)