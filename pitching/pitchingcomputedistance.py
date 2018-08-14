#!/usr/local/Cellar/python/2.7.14/bin/python2
import MySQLdb
import pandas as pd
import scipy as sp
import ConfigParser
import argparse 
from scipy.spatial.distance import mahalanobis
from scipy.spatial.distance import euclidean

parser = argparse.ArgumentParser()
parser.add_argument("year", help="the year to generate comps for", type=int)
args = parser.parse_args()

config = ConfigParser.ConfigParser()
config.sections()
config.read("dbi.conf")

db = MySQLdb.connect(host=config.get('history', 'host'),    # your host, usually localhost
                     user=config.get('history', 'user'),         # your username
                     passwd=config.get('history', 'password'),  # your password
                     db=config.get('history', 'database'))        # name of the data base

cur = db.cursor()
cur.execute("select p.uid, p.year, p.nameurl, p.year, p.age, p.league from pitchers p where year = %d" % args.year)

for row in cur.fetchall():
    uid = row[0]
    year = row[1]
    nameurl = row[2] 
    year = row[3]
    age = row[4]
    level = row[5]

    minage = age - 3.0
    maxage = age + 3.0    

    playersql = "select p.uid, p.nameurl, p.year, p.age, ps.bbpercent, ps.hrpercent, ps.kpercent, ps.ksquared, ps.gspercent " \
                "from pitchers p, pitcherstats ps where p.uid=ps.uid " \
                "and p.uid=%d" % (uid)
    print playersql
    playerdf = pd.read_sql(playersql, con=db) 

    compsql = "select p.uid, p.nameurl, p.year, p.age, ps.bbpercent, ps.hrpercent, ps.kpercent, ps.ksquared, ps.gspercent " \
                "from pitchers p, pitcherstats ps where p.uid=ps.uid " \
                "and p.age > %f and p.age < %f and p.league='%s' " \
                "order by p.year desc" % (minage, maxage, level)
    print compsql
    df = pd.read_sql(compsql, con=db)

    covmx = df.iloc[:-1,4:9].cov()
    invcovmx = sp.linalg.inv(covmx)

    for index, row in df.iterrows():
      comp = playerdf.iloc[0,4:9].values
      array = df.iloc[index,4:9].values
      m =  mahalanobis(comp, array, invcovmx)
      e = euclidean(comp,array)
      
      insertsql = "insert into pitchercomps(uid, year, compuid, mahalanobis, euclidean) " \
                  " VALUES (%d, %d, %d, %f, %f)" % (uid, year, df.iloc[index,0], m, e)   

      print insertql  
    
      db.commit()
 
db.close()
