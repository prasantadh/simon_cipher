--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:33:21 01/21/2018
-- Design Name:   
-- Module Name:   D:/pa1038-DO NOT DELETE/simon_32_64/test_top_module.vhd
-- Project Name:  simon_32_64
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: top_module
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_top_module IS
END test_top_module;
 
ARCHITECTURE behavior OF test_top_module IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT top_module
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         enc : IN  std_logic;
         key : IN  std_logic_vector(63 downto 0);
         d : IN  std_logic_vector(31 downto 0);
         q : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '1';
   signal enc : std_logic := '0';
   signal key : std_logic_vector(63 downto 0) := (others => '0');
   signal d : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal q : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: top_module PORT MAP (
          clk => clk,
          rst => rst,
          enc => enc,
          key => key,
          d => d,
          q => q
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;
			enc <= '1';
			key <= X"1918111009080100";
			d <= X"65656877";
			-- assert(q = c69be9bb)

      wait for clk_period*10;
			rst <= '0';
		
		wait for clk_period * 100;
			rst <= '1';
			enc <= '0';
			d <= X"c69be9bb";
		
		wait for clk_period * 10;
			rst <= '0';
		

      -- insert stimulus here 

      wait;
   end process;

END;
