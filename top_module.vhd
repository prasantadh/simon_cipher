----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:09:54 01/20/2018 
-- Design Name: 
-- Module Name:    top_module - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top_module is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
			  enc : in STD_LOGIC;
           key : in  STD_LOGIC_VECTOR (63 downto 0);
           d : in  STD_LOGIC_VECTOR (31 downto 0);
           q : out  STD_LOGIC_VECTOR (31 downto 0));
end top_module;

architecture Behavioral of top_module is

signal state : integer range 0 to 31;	-- signal to keep track of the state
signal currKeys : STD_LOGIC_VECTOR (63 downto 0);	-- small key buffer where key expansion happens
signal z : STD_LOGIC_VECTOR (0 to 31) := "11111010001001010110000111001101"; --given constant for the cipher

-- declare a ram to store the keys (pre-computation is necessary for decryption)
type key_storage is array(0 to 31) of STD_LOGIC_VECTOR(15 downto 0);
signal keys : key_storage;
signal keys_filled : bit := '0';

-- enable the circuit on first rising edge after reset goes down
signal en : bit := '0'; 
signal input_is_read : boolean := false;

--register to keep track of input
signal text : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
begin

-- state machine 
-- simply counts from 0 to 31 in a circular fashion
state_machine_process: 
process (clk, rst)
begin 
	if rst = '1' then
		state <= 0;
		keys_filled <= '0';
	elsif rising_edge(clk) then
		if en = '0' then
			en <= '1';
		elsif keys_filled = '0' then
			if state = 31 then
				keys_filled <= '1';
				if enc = '1' then
					state <= 0;
				else 
					state <= 31;
				end if;
			else
				state <= state + 1;
			end if;
		else
			if enc = '1' then
				if state = 31 then
					state <= 0;
				else
					state <= state + 1;
				end if;
			else
				if state = 0 then 
					state <= 31;
				else 
					state <= state - 1;
				end if;
			end if;
		end if;
	end if;
end process;

key_generation_process:
process(clk, rst, en, keys_filled)
variable sn3, sn1, tmp, tmp2 : STD_LOGIC_VECTOR (15 downto 0); -- sn3 means S^(-3) in the specs
variable rkey : STD_LOGIC_VECTOR (15 downto 0);
begin
	if rst='1' then -- only works everytime reset changes
		-- do nothing
	elsif keys_filled = '0' and en = '1' and rising_edge(clk) then
		if state = 0 then
			keys(state) <= key(15 downto 0);
			currKeys(15 downto 0) <= key(15 downto 0);
		elsif state = 1 then
			keys(state) <= key(31 downto 16);
			currKeys(31 downto 16) <= key(31 downto 16);
		elsif state = 2 then
			keys(state) <= key(47 downto 32);
			currKeys(47 downto 32) <= key(47 downto 32);
		elsif state = 3 then
			keys(state) <= key(63 downto 48);
			currKeys(63 downto 48) <= key(63 downto 48);
		else
			sn3 := currKeys(50 downto 48) & currKeys(63 downto 51);
			tmp := sn3 xor currKeys(31 downto 16);
			sn1 := tmp(0) & tmp(15 downto 1);
			tmp2 := sn1 xor tmp;
			rkey := (not keys(state-4)) xor tmp2 xor ("000000000000000" & z(state-4 to state-4)) xor x"0003";
			
			currKeys(47 downto 00) <= currKeys(63 downto 16);
			currKeys(63 downto 48)  <= rKey;
			
			keys(state) <= rkey;
		end if;
	end if;
end process;

round_process:
process(clk, rst, state, keys_filled)
variable s1, s8, s2, result : STD_LOGIC_VECTOR(15 downto 0) := X"0000";
begin
	if rst = '1' then
		q <= X"00000000";
	elsif rising_edge(clk) then
		if keys_filled = '1' then
			s1 := text(30 downto 16) & text(31);
			s8 := text(23 downto 16) & text(31 downto 24);
			s2 := text(29 downto 16) & text(31 downto 30);
			result := (s1 and s8) xor text(15 downto 0) xor s2 xor keys(state);
			if (enc = '1' and state = 31) then
				q <= result & text(31 downto 16);
				text <= d;
			elsif (enc = '0' and state = 0) then
				q <= text(31 downto 16) & result; 
				text <= d(15 downto 0)  & d(31 downto 16);
			else 
				text(15 downto 00) <= text(31 downto 16);
				text(31 downto 16) <= result;
			end if;
		else
			if (enc = '1') then
				text <= d;
			else
				text <= d(15 downto 0)  & d(31 downto 16);
			end if;
		end if;
	end if;	
end process;

end Behavioral;

