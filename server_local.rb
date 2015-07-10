
require 'socket'
require 'rdbi-driver-sqlite3'

socket = UDPSocket.new
socket.bind("10.28.32.28", 2102) # Sempre observar o IP (Quando local no servidor = 127.0.0.1)
socket2serv = UDPSocket.new
socket2serv.connect("10.28.32.28", 2102) # Sempre observar o IP (Quando local servidor = 127.0.0.1)
"Server Local Online!!!"
dbh = RDBI.connect(:SQLite3, :database => "reg_emails.db")
ip_central = "10.28.32.28"
port_central = 2101
aspas = '"'
consulta = nil

puts "----- MENU - SERVIDOR LOCAL -----"
puts ""

loop {
	
	puts ""
	puts "1 - Registrar dominio."
	puts "2 - Solicitar IP de dominio."
	puts "3 - Simulador de cliente."
	puts "4 - Sair."
	puts ""
	esc = gets.chomp.to_i
	
	case esc
		when 1
			puts "Digite o endereco do dominio:"
			dominio = gets.chomp.to_s
			puts
			puts "Digite o endereco IP (formato: X.X.X.X):"
			ip = gets.chomp.to_s
			socket2serv.send "REG #{dominio} #{ip}", 0, ip_central, port_central
			puts ""
			resposta, sender = socket2serv.recvfrom(1024)
			puts resposta
		when 2
			puts ""
			puts "Digite o endereco do dominio:"
			dominio = gets.chomp.to_s
			socket2serv.send "IP #{dominio}", 0, ip_central, port_central
			puts ""
			resposta, sender = socket2serv.recvfrom(1024)
			puts resposta
		when 3 #INACABADO, MUDAR VARIAVEIS PARA LETRAS MINUSCULAS
			loop {
				begin
					puts ""
					puts "1 - Cadastrar email."
					puts "2 - Verificar caixa de entrada."
					puts "3 - Sair."
					puts ""
					OP ||= gets.chomp.to_i
					
					case OP
						when 1
							puts ""
							puts "Digite um email:"
							EMAIL = gets.chomp.to_s
							puts ""
							RS = DBH.execute("select EMAIL from EMAILS where EMAIL = #{aspas}#{EMAIL}#{aspas}")
							RS.fetch(:all).each do |row|
								CONSULTA = row
							end
							if CONSULTA == nil
								DBH.execute("insert into EMAILS (EMAIL) values (#{aspas}#{EMAIL}#{aspas})")
								puts ""
								puts "----- AVISO: EMAIL CADASTRADO COM SUCESSO! -----"
								puts ""
							elsif CONSULTA != nil
								puts ""
								puts "----- AVISO: EMAIL INVALIDO OU EM USO, TENTE NOVAMENTE! -----"
								puts ""
							end
							DBH.disconnect
						when 2
							puts ""
							puts "Digite o seu email:"
							EMAIL = gets.chomp.to_s
							RS = DBH.execute("select EMAIL from EMAILS where EMAIL = #{aspas}#{EMAIL}#{aspas}")
							RS.fetch(:all).each do |row|
								CONSULTA = row
							end
							if CONSULTA == nil
								puts ""
								puts "----- AVISO: EMAIL INEXISTENTE, TENTE NOVAMENTE! -----"
								puts ""
							elsif CONSULTA != nil
								RS = DBH.execute("select CAIXAENTRADA from INBOX i inner join EMAILS e where e.ID = i.FKID and e.EMAIL = #{aspas}#{EMAIL}#{aspas}")
								RS.fetch(:all).each do |row|
									CONSULTA = row
								end
								puts ""
								puts CONSULTA
								puts ""
							end
							DBH.disconnect
						when 3
							break
						else
							puts "----- Opcao invalida, tente novamente! -----"
					end
				rescue
					puts "----- FALHA! -----"
				end
			}
		when 4
			break
		else
		 puts "----- Opcao invalida, tente novamente! -----"
	end
}
SOCKET.close
