import csv
f = open('amd_stock_data.csv','r')
r = csv.reader(f)
next(r,None)
obvList = []
volList = []

# obvList.append(['Date', 'On Balance Volume'])
for i,n in enumerate(r):

    curr = n[1]
    volume = n[8]
    date = n[3]
    pair = (date,curr,volume)
    volList.append(pair)
volList.reverse() #volList contains the date, curr and volume


prev = 0
obv = 0
curr = 0
volume = 0
i=0
for n in volList:  #time to calculate and input into obvList
    date = n[0]
    prev = curr
    curr = n[1]
    volume = n[2]
    if i==0:
        obv=0
    elif float(curr)>float(prev):
        obv+=float(volume)
    elif float(curr)<float(prev):
        obv-=float(volume)

    obvList.append([date,obv])
    i = i+1

obvListWHeader = []
obvListWHeader.append(['Date', 'OBV'])
for i in obvList:
    obvListWHeader.append(i)




with open('obv.csv', 'w', newline='') as fp:
    w = csv.writer(fp, delimiter=',')
    w.writerows(obvListWHeader)

# print(obvList[0])
