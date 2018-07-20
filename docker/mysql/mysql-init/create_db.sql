create database  IF NOT EXISTS born_db DEFAULT CHARACTER SET = `utf8`;
grant all on born_db.* to 'bornner'@'%' identified by '123qwe';