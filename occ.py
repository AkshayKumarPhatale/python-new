#text = "INSERT INTO $MAO_004_DTL_TRNSFRM (FROM $SR_RADJ_QA.$CMS_LD_LOG_TBL WHERE SUBJ_AREA_NM = '$CMS_SUBJ_AREA_NM'"
index = 0
flag = False
endposition = 0
startposition = 0
l = []
with open(r"C:\Users\home\Desktop\py\CLINCAL_TRIMED_APID9617_MERGE.sh", "rt") as fin:
    for text in fin:
        for element in range(0, len(text)):
            if text[element] == "$":
                flag = True
                startposition = element
            elif flag:
                if text[element] == ";" or text[element] == "\'" or text[element] == "." or text[element] == ")" or text[element] == " ":
                    endposition = element
                    l.append(text[startposition + 1:endposition])
                    flag = False

for item in l:
    print(item)
