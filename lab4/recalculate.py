from pathlib import Path
import csv,json
p=Path(__file__).resolve().parent
stages=[('01-start','Начальный этап',1000,1,1,2,1,0,2),('02-partners','Тестирование партнёрами',30000,20,10,20,5,1,10),('03-production','Продовое решение',1000000,500,100,200,20,2,100)]
# N, object GiB, DB GiB, egress GiB, logs GiB, warm API instances, peak AI requests/sec
rows=[]
for key,title,n,obj,db,net,logs,warm,peak in stages:
 api_calls=3*n; active=n*8+api_calls*.2
 costs={'AI inference':n*(4000*.25+500*1.5)/1e6,
 'Cloud Run active':active*(.000024+.5*.0000025)+4*n*.4/1e6,
 'Cloud Run warm ceiling':warm*730*3600*(.0000025+.5*.0000025),
 'Cloud Storage':obj*.02+n*.005/1000+n*.0004/1000,
 'Firestore':db*.15+10*n*.03/100000+3*n*.09/100000,
 'Firestore backup/PITR reserve':db*.15+db*.03,
 'Internet egress':net*.12,
 'Cloud Tasks':0 if n==1000 else 2*n*.4/1e6,
 'Logging':logs*.5,
 'Artifact Registry':.1*(1 if n==1000 else 3 if n==30000 else 10),
 'CI monitoring operations reserve':2 if n==1000 else 10 if n==30000 else 50}
 rows.append({'stage':title,'requests':n,**costs,'subtotal':sum(costs.values()),'with_20_percent_reserve':sum(costs.values())*1.2})
with (p/'costs.csv').open('w') as f:
 w=csv.DictWriter(f,fieldnames=rows[0].keys());w.writeheader();w.writerows(rows)
(p/'costs.json').write_text(json.dumps(rows,ensure_ascii=False,indent=2))
print(json.dumps(rows,ensure_ascii=False,indent=2))
