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
