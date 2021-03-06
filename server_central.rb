
require 'socket'
require 'rdbi-driver-sqlite3'

socket = UDPSocket.new
socket.bind("127.0.0.1", 2101)
puts ""
puts "----- Central Server Online!!! -----"
dbh = RDBI.connect( :SQLite3, :database => "reg_dominios.db" )
aspas = '"'
reply = nil

loop {
	armazenaSolicitacao, sender = socket.recvfrom(1024)
	puts ""
	puts "----- Connected! -----"
	puts ""
	#solicitacao = Array.new(3)
	solicitacao = armazenaSolicitacao.split
	c_ip = sender[3]
	c_port = sender[1]
	if solicitacao[0] == "REG" && solicitacao.length == 3
		if solicitacao[1] != nil && solicitacao[2] != nil
			begin
				puts "----- RECEBENDO SOLICITACAO DE REGISTRO DE DOMINIO... -----"
				dbh.execute("insert into REGISTROS (DOMINIO, IP) values ( #{aspas}#{solicitacao[1]}#{aspas}, #{aspas}#{solicitacao[2]}#{aspas})")
				puts "----- REGOK ----- REGISTRO DE DOMINIO REALIZADO COM SUCESSO!"
				socket.send "REGOK", 0 , c_ip, c_port
			rescue
				puts "----- REGFALHA ----- O DOMINIO JA SE ENCONTRA REGISTRADO!"
				socket.send "REGFALHA", 0, c_ip, c_port
			end
		#else # Esse else pode comentar depois
			#puts "----- AVISO: FALHA INESPERADA! -----"
			#socket.send "FALHA", 0, c_ip, c_port
		end
	elsif solicitacao[0] == "IP" && solicitacao.length == 2
		if solicitacao[1] != nil
			puts "----- RECEBENDO SOLICITACAO DE IP... -----"
			rs = dbh.execute("select IP from REGISTROS where DOMINIO = #{aspas}#{solicitacao[1]}#{aspas}")
			rs.fetch(:all).each do |row|
				reply = row[0]
			end
			puts reply
			if reply != nil
				puts "----- IPOK ----- ENVIANDO IP..."
				#reply
				socket.send("IPOK #{reply}", 0, c_ip, c_port)
			elsif reply == nil
				puts "----- IPFALHA ----- AVISO: ENDERECO IP NAO ENCONTRADO!"
				socket.send "IPFALHA", 0, c_ip, c_port
			end
		#else # Esse else pode comentar depois
			#puts "----- AVISO: FALHA INESPERADA! -----"
			#socket.send "FALHA", 0, c_ip, c_port
		end
	else
		puts "----- AVISO: FALHA INESPERADA! -----"
		socket.send "FALHA", 0, c_ip, c_port	
	end
}
socket.close
