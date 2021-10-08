%let zipfile="~/saida.zip";
%let csvfile="~/arquivo.csv"; 
%let csf="arquivo.csv"; /*necessario nome do arquivo sem path*/
%let zipurl="http://url/download/saida.zip";

/* baixa o zip com o csv */
filename saida &zipfile;                      
proc http out=saida 
		url=&zipurl
		method="get";
run;

/* Lista o conteudo do zip */
filename saida ZIP &zipfile;
data conteudo(keep=memname isFolder);
	length memname $200 isFolder 8;
	fid=dopen("saida");
	if fid=0 then
		stop;
	memcount=dnum(fid);
	do i=1 to memcount;
		memname=dread(fid, i);
		isFolder=(first(reverse(trim(memname)))='/');
		output;
	end;
	rc=dclose(fid);
run;

/* exibe o conteudo da listagem */
title "Arquivos no zipfile";
proc print data=conteudo noobs N;
run;

/* extrai arquivo especifico do zip */
filename saida ZIP &zipfile;
filename extrai &csvfile;
data _null_;
	infile saida(&csf) lrecl=256 recfm=F length=length eof=eof unbuf;
	file extrai lrecl=256 recfm=N;
	input;
	put _infile_ $varying256. length;
	return;
eof:
	stop;
run;

/* carrega o csv numa tabela */
filename extrai &csvfile encoding="latin1";
proc import file=extrai out=CSVTABLE dbms=csv replace;
	delimiter=';';
run;