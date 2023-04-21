library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity memoriaROM is
   generic (
          dataWidth: natural := 12;
          addrWidth: natural := 3
    );
   port (
          Endereco : in std_logic_vector (addrWidth-1 DOWNTO 0);
          Dado : out std_logic_vector (dataWidth-1 DOWNTO 0)
    );
end entity;

architecture assincrona of memoriaROM is

  type blocoMemoria is array(0 TO 2**addrWidth - 1) of std_logic_vector(dataWidth-1 DOWNTO 0);

  function initMemory
        return blocoMemoria is variable tmp : blocoMemoria := (others => (others => '0'));
		  
		  constant NOP  	 : std_logic_vector(3 downto 0) := "0000";
		  constant LDA  	 : std_logic_vector(3 downto 0) := "0001";
		  constant SOMA 	 : std_logic_vector(3 downto 0) := "0010";
		  constant SUB  	 : std_logic_vector(3 downto 0) := "0011";
		  constant LDI  	 : std_logic_vector(3 downto 0) := "0100";
		  constant STA  	 : std_logic_vector(3 downto 0) := "0101";
		  constant JMP  	 : std_logic_vector(3 downto 0) := "0110";
		  constant JEQ  	 : std_logic_vector(3 downto 0) := "0111";
		  constant CEQ  	 : std_logic_vector(3 downto 0) := "1000";
		  constant JSR  	 : std_logic_vector(3 downto 0) := "1001";
		  constant RET  	 : std_logic_vector(3 downto 0) := "1010";
		  constant OP_AND  : std_logic_vector(3 downto 0) := "1011";

  begin		  
			
		--  ------------------ SETUP --------------------

		-- Limpa Displays
		tmp(0) := LDI & '0' & x"00";	-- #LDI $0
		tmp(1) := STA & '1' & x"20";	-- #STA @288
		tmp(2) := STA & '1' & x"21";	-- #STA @289
		tmp(3) := STA & '1' & x"22";	-- #STA @290
		tmp(4) := STA & '1' & x"23";	-- #STA @291
		tmp(5) := STA & '1' & x"24";	-- #STA @292
		tmp(6) := STA & '1' & x"25";	-- #STA @293

		-- Limpa Leds
		tmp(7) := LDI & '0' & x"00";	-- #LDI $0
		tmp(8) := STA & '1' & x"00";	-- #STA @256
		tmp(9) := STA & '1' & x"01";	-- #STA @257
		tmp(10) := STA & '1' & x"02";	-- #STA @258

		--  Inicializando posicao de constantes imutáveis
		--  Reservado Endereco 0 a 9
		tmp(11) := LDI & '0' & x"00";	-- #LDI $0
		tmp(12) := STA & '0' & x"00";	-- #STA @0         	--  Constante 0
		tmp(13) := LDI & '0' & x"01";	-- #LDI $1         	--  Constante 1
		tmp(14) := STA & '0' & x"01";	-- #STA @1

		--  Inicializando posições que guardaram Unidades do contador
		--  Reservado Endereco 10 a 19
		tmp(15) := LDI & '0' & x"00";	-- #LDI $0
		tmp(16) := STA & '0' & x"0A";	-- #STA @10       	--  MEN[10] = Unidades
		tmp(17) := STA & '0' & x"0B";	-- #STA @11       	--  MEN[11] = Dezenas
		tmp(18) := STA & '0' & x"0C";	-- #STA @12       	--  MEN[12] = Centenas
		tmp(19) := STA & '0' & x"0D";	-- #STA @13       	--  MEN[13] = Unidade de Milhar
		tmp(20) := STA & '0' & x"0E";	-- #STA @14       	--  MEN[14] = Centena de Milhar
		tmp(21) := STA & '0' & x"0F";	-- #STA @15       	--  MEN[15] = Unidade de Milhão

		tmp(22) := JMP & '0' & x"20";	-- #JMP @32	--  Pula para Rotina Principal
		tmp(23) := NOP & '0' & x"00";	-- #NOP

		--  -------------- INCREMENTA CONTADOR ---------------


		tmp(24) := STA & '1' & x"FF";	-- #STA @511       	--  Endereco 511 : Limpa Flag FlipFlop KEY0
		tmp(25) := LDA & '0' & x"0A";	-- #LDA @10        	--  REGA = Unidade
		tmp(26) := SOMA & '0' & x"01";	-- #SOMA @1        	--  REGA = Unidade + 1
		tmp(27) := STA & '0' & x"0A";	-- #STA @10        	--  MEN[10] = Unidade_incrementada
		tmp(28) := STA & '1' & x"20";	-- #STA @288       	--  HEX0 = Unidade
		tmp(29) := STA & '1' & x"02";	-- #STA @258       	--  Salva bit(0) do valor do contador em LEDR9
		tmp(30) := JMP & '0' & x"20";	-- #JMP @32	-- JMP .VERIFICA_KEY0
		tmp(31) := NOP & '0' & x"00";	-- #NOP

		--  -------------- ROTINA PRINCIPAL -----------------

		--  Verifica estado do KEY0
		tmp(32) := LDA & '1' & x"60";	-- #LDA @352                      	--  Lê KEY0
		tmp(33) := OP_AND & '0' & x"01";	-- #OP_AND @1                     	--  Tira valores lixos dos outros 7bits
		tmp(34) := CEQ & '0' & x"00";	-- #CEQ @0                        	--  Verifica se foi apertado (KEY0 = 0 ?)
		tmp(35) := JEQ & '0' & x"20";	-- #JEQ @32	--  NAO APERTADO
		tmp(36) := NOP & '0' & x"00";	-- #NOP
		tmp(37) := JSR & '0' & x"18";	-- #JSR @24	--  APERTADO
		tmp(38) := NOP & '0' & x"00";	-- #NOP
		tmp(39) := NOP & '0' & x"00";	-- #NOP

		 
		return tmp;
    end initMemory;

    signal memROM : blocoMemoria := initMemory;

begin
    Dado <= memROM (to_integer(unsigned(Endereco)));
end architecture;