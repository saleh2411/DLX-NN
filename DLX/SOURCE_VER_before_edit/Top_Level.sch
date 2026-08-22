<?xml version="1.0" encoding="UTF-8"?>
<drawing version="7">
    <attr value="spartan6" name="DeviceFamilyName">
        <trait delete="all:0" />
        <trait editname="all:0" />
        <trait edittrait="all:0" />
    </attr>
    <netlist>
        <signal name="Card_Sel" />
        <signal name="Rsel" />
        <signal name="AI(9:0)" />
        <signal name="D_IN(31:0)" />
        <signal name="WR_IN_N" />
        <signal name="RACK_N" />
        <signal name="MAO(31:0)" />
        <signal name="MDO(31:0)" />
        <signal name="SACK_N" />
        <signal name="IN_INIT" />
        <signal name="CLK" />
        <signal name="STEP_EN" />
        <signal name="AS_N" />
        <signal name="WR_OUT_N" />
        <signal name="RESET" />
        <signal name="R_DO(31:0)" />
        <signal name="sdClk_o" />
        <signal name="sdBs_o(1:0)" />
        <signal name="sdDqml_o" />
        <signal name="sdDqmh_o" />
        <signal name="sdWe_bo" />
        <signal name="sdCas_bo" />
        <signal name="sdRas_bo" />
        <signal name="sdCe_bo" />
        <signal name="sdCke_o" />
        <signal name="fpgaClk_i" />
        <signal name="sdClkFb_i" />
        <signal name="sdData_io(15:0)" />
        <signal name="sdAddr_o(12:0)" />
        <signal name="SDO(31:0)" />
        <signal name="ACK_N" />
        <signal name="reg_addr(4:0)" />
        <signal name="STOP_N" />
        <signal name="XLXN_1" />
        <signal name="XLXN_2" />
        <signal name="D_RAM_OUT(31:0)" />
        <signal name="DO(31:0)" />
        <signal name="D_IN(19)" />
        <signal name="D_IN(2:1)" />
        <signal name="D_IN(31:30)" />
        <signal name="D_IN(29:25)" />
        <signal name="D_IN(24:23)" />
        <signal name="D_IN(18)" />
        <signal name="D_IN(17)" />
        <signal name="D_IN(16)" />
        <signal name="D_IN(15)" />
        <signal name="D_IN(14)" />
        <signal name="D_IN(13)" />
        <signal name="D_IN(12)" />
        <signal name="D_IN(11)" />
        <signal name="D_IN(10)" />
        <signal name="D_IN(9)" />
        <signal name="D_IN(0)" />
        <signal name="XLXN_76" />
        <signal name="XLXN_77" />
        <signal name="D_IN(3)" />
        <signal name="D_IN(4)" />
        <signal name="D_IN(5)" />
        <signal name="D_IN(6)" />
        <signal name="D_IN(7)" />
        <signal name="D_IN(8)" />
        <signal name="D_IN(20)" />
        <signal name="D_IN(21)" />
        <signal name="D_IN(22)" />
        <port polarity="Output" name="sdClk_o" />
        <port polarity="Output" name="sdBs_o(1:0)" />
        <port polarity="Output" name="sdDqml_o" />
        <port polarity="Output" name="sdDqmh_o" />
        <port polarity="Output" name="sdWe_bo" />
        <port polarity="Output" name="sdCas_bo" />
        <port polarity="Output" name="sdRas_bo" />
        <port polarity="Output" name="sdCe_bo" />
        <port polarity="Output" name="sdCke_o" />
        <port polarity="Input" name="fpgaClk_i" />
        <port polarity="Input" name="sdClkFb_i" />
        <port polarity="BiDirectional" name="sdData_io(15:0)" />
        <port polarity="Output" name="sdAddr_o(12:0)" />
        <blockdef name="IO_LOGIC_U">
            <timestamp>2015-7-8T11:14:45</timestamp>
            <rect width="304" x="64" y="-1280" height="1280" />
            <line x2="0" y1="-1248" y2="-1248" x1="64" />
            <line x2="0" y1="-1136" y2="-1136" x1="64" />
            <line x2="0" y1="-1024" y2="-1024" x1="64" />
            <line x2="0" y1="-912" y2="-912" x1="64" />
            <line x2="0" y1="-800" y2="-800" x1="64" />
            <line x2="0" y1="-688" y2="-688" x1="64" />
            <line x2="0" y1="-576" y2="-576" x1="64" />
            <rect width="64" x="0" y="-476" height="24" />
            <line x2="0" y1="-464" y2="-464" x1="64" />
            <rect width="64" x="0" y="-364" height="24" />
            <line x2="0" y1="-352" y2="-352" x1="64" />
            <rect width="64" x="0" y="-252" height="24" />
            <line x2="0" y1="-240" y2="-240" x1="64" />
            <rect width="64" x="0" y="-140" height="24" />
            <line x2="0" y1="-128" y2="-128" x1="64" />
            <line x2="432" y1="-1248" y2="-1248" x1="368" />
            <line x2="432" y1="-1184" y2="-1184" x1="368" />
            <line x2="432" y1="-1120" y2="-1120" x1="368" />
            <line x2="432" y1="-1056" y2="-1056" x1="368" />
            <line x2="432" y1="-992" y2="-992" x1="368" />
            <line x2="432" y1="-928" y2="-928" x1="368" />
            <line x2="432" y1="-864" y2="-864" x1="368" />
            <line x2="432" y1="-800" y2="-800" x1="368" />
            <line x2="432" y1="-736" y2="-736" x1="368" />
            <line x2="432" y1="-672" y2="-672" x1="368" />
            <line x2="432" y1="-608" y2="-608" x1="368" />
            <line x2="432" y1="-544" y2="-544" x1="368" />
            <line x2="432" y1="-480" y2="-480" x1="368" />
            <line x2="432" y1="-416" y2="-416" x1="368" />
            <line x2="432" y1="-352" y2="-352" x1="368" />
            <rect width="64" x="368" y="-300" height="24" />
            <line x2="432" y1="-288" y2="-288" x1="368" />
            <rect width="64" x="368" y="-236" height="24" />
            <line x2="432" y1="-224" y2="-224" x1="368" />
            <rect width="64" x="368" y="-172" height="24" />
            <line x2="432" y1="-160" y2="-160" x1="368" />
            <rect width="64" x="368" y="-108" height="24" />
            <line x2="432" y1="-96" y2="-96" x1="368" />
            <rect width="64" x="368" y="-44" height="24" />
            <line x2="432" y1="-32" y2="-32" x1="368" />
        </blockdef>
        <blockdef name="monitor_salve">
            <timestamp>2025-12-4T14:53:0</timestamp>
            <rect width="320" x="64" y="-640" height="640" />
            <line x2="0" y1="-608" y2="-608" x1="64" />
            <line x2="0" y1="-544" y2="-544" x1="64" />
            <line x2="0" y1="-480" y2="-480" x1="64" />
            <line x2="0" y1="-416" y2="-416" x1="64" />
            <line x2="0" y1="-352" y2="-352" x1="64" />
            <line x2="0" y1="-288" y2="-288" x1="64" />
            <rect width="64" x="0" y="-236" height="24" />
            <line x2="0" y1="-224" y2="-224" x1="64" />
            <rect width="64" x="0" y="-172" height="24" />
            <line x2="0" y1="-160" y2="-160" x1="64" />
            <rect width="64" x="0" y="-108" height="24" />
            <line x2="0" y1="-96" y2="-96" x1="64" />
            <rect width="64" x="0" y="-44" height="24" />
            <line x2="0" y1="-32" y2="-32" x1="64" />
            <line x2="448" y1="-608" y2="-608" x1="384" />
            <rect width="64" x="384" y="-332" height="24" />
            <line x2="448" y1="-320" y2="-320" x1="384" />
            <rect width="64" x="384" y="-44" height="24" />
            <line x2="448" y1="-32" y2="-32" x1="384" />
        </blockdef>
        <blockdef name="fd">
            <timestamp>2000-1-1T10:10:10</timestamp>
            <rect width="256" x="64" y="-320" height="256" />
            <line x2="64" y1="-128" y2="-128" x1="0" />
            <line x2="64" y1="-256" y2="-256" x1="0" />
            <line x2="320" y1="-256" y2="-256" x1="384" />
            <line x2="64" y1="-128" y2="-144" x1="80" />
            <line x2="80" y1="-112" y2="-128" x1="64" />
        </blockdef>
        <blockdef name="or2">
            <timestamp>2000-1-1T10:10:10</timestamp>
            <line x2="64" y1="-64" y2="-64" x1="0" />
            <line x2="64" y1="-128" y2="-128" x1="0" />
            <line x2="192" y1="-96" y2="-96" x1="256" />
            <arc ex="192" ey="-96" sx="112" sy="-48" r="88" cx="116" cy="-136" />
            <arc ex="48" ey="-144" sx="48" sy="-48" r="56" cx="16" cy="-96" />
            <line x2="48" y1="-144" y2="-144" x1="112" />
            <arc ex="112" ey="-144" sx="192" sy="-96" r="88" cx="116" cy="-56" />
            <line x2="48" y1="-48" y2="-48" x1="112" />
        </blockdef>
        <blockdef name="or2b1">
            <timestamp>2000-1-1T10:10:10</timestamp>
            <line x2="32" y1="-64" y2="-64" x1="0" />
            <circle r="12" cx="44" cy="-64" />
            <line x2="64" y1="-128" y2="-128" x1="0" />
            <line x2="192" y1="-96" y2="-96" x1="256" />
            <line x2="48" y1="-48" y2="-48" x1="112" />
            <arc ex="112" ey="-144" sx="192" sy="-96" r="88" cx="116" cy="-56" />
            <line x2="48" y1="-144" y2="-144" x1="112" />
            <arc ex="48" ey="-144" sx="48" sy="-48" r="56" cx="16" cy="-96" />
            <arc ex="192" ey="-96" sx="112" sy="-48" r="88" cx="116" cy="-136" />
        </blockdef>
        <blockdef name="DLX">
            <timestamp>2026-6-27T7:49:29</timestamp>
            <line x2="464" y1="96" y2="96" x1="400" />
            <line x2="464" y1="160" y2="160" x1="400" />
            <rect width="64" x="400" y="212" height="24" />
            <line x2="464" y1="224" y2="224" x1="400" />
            <rect width="64" x="400" y="276" height="24" />
            <line x2="464" y1="288" y2="288" x1="400" />
            <line x2="464" y1="32" y2="32" x1="400" />
            <line x2="0" y1="-1888" y2="-1888" x1="64" />
            <line x2="0" y1="-1520" y2="-1520" x1="64" />
            <line x2="0" y1="-1152" y2="-1152" x1="64" />
            <line x2="0" y1="-784" y2="-784" x1="64" />
            <rect width="64" x="0" y="-428" height="24" />
            <line x2="0" y1="-416" y2="-416" x1="64" />
            <rect width="64" x="0" y="-60" height="24" />
            <line x2="0" y1="-48" y2="-48" x1="64" />
            <line x2="464" y1="-1888" y2="-1888" x1="400" />
            <line x2="464" y1="-1696" y2="-1696" x1="400" />
            <line x2="464" y1="-1632" y2="-1632" x1="400" />
            <line x2="464" y1="-1568" y2="-1568" x1="400" />
            <line x2="464" y1="-1504" y2="-1504" x1="400" />
            <line x2="464" y1="-1440" y2="-1440" x1="400" />
            <line x2="464" y1="-1376" y2="-1376" x1="400" />
            <line x2="464" y1="-1312" y2="-1312" x1="400" />
            <line x2="464" y1="-1248" y2="-1248" x1="400" />
            <line x2="464" y1="-1184" y2="-1184" x1="400" />
            <line x2="464" y1="-1120" y2="-1120" x1="400" />
            <line x2="464" y1="-1056" y2="-1056" x1="400" />
            <line x2="464" y1="-992" y2="-992" x1="400" />
            <line x2="464" y1="-928" y2="-928" x1="400" />
            <line x2="464" y1="-864" y2="-864" x1="400" />
            <line x2="464" y1="-800" y2="-800" x1="400" />
            <line x2="464" y1="-672" y2="-672" x1="400" />
            <line x2="464" y1="-608" y2="-608" x1="400" />
            <line x2="464" y1="-544" y2="-544" x1="400" />
            <line x2="464" y1="-480" y2="-480" x1="400" />
            <rect width="64" x="400" y="-428" height="24" />
            <line x2="464" y1="-416" y2="-416" x1="400" />
            <rect width="64" x="400" y="-364" height="24" />
            <line x2="464" y1="-352" y2="-352" x1="400" />
            <rect width="64" x="400" y="-300" height="24" />
            <line x2="464" y1="-288" y2="-288" x1="400" />
            <rect width="64" x="400" y="-236" height="24" />
            <line x2="464" y1="-224" y2="-224" x1="400" />
            <rect width="64" x="400" y="-44" height="24" />
            <line x2="464" y1="-32" y2="-32" x1="400" />
            <rect width="336" x="64" y="-1920" height="2240" />
        </blockdef>
        <blockdef name="buf">
            <timestamp>2000-1-1T10:10:10</timestamp>
            <line x2="64" y1="-32" y2="-32" x1="0" />
            <line x2="128" y1="-32" y2="-32" x1="224" />
            <line x2="128" y1="0" y2="-32" x1="64" />
            <line x2="64" y1="-32" y2="-64" x1="128" />
            <line x2="64" y1="-64" y2="0" x1="64" />
        </blockdef>
        <block symbolname="IO_LOGIC_U" name="XLXI_23">
            <blockpin signalname="AS_N" name="AS_N_i" />
            <blockpin signalname="fpgaClk_i" name="fpgaClk_i" />
            <blockpin signalname="IN_INIT" name="in_init_i" />
            <blockpin signalname="RACK_N" name="RACK_N_i" />
            <blockpin signalname="SACK_N" name="SACK_N_i" />
            <blockpin signalname="sdClkFb_i" name="sdClkFb_i" />
            <blockpin signalname="WR_OUT_N" name="WR_N_i" />
            <blockpin signalname="MAO(31:0)" name="MA_i(31:0)" />
            <blockpin signalname="MDO(31:0)" name="MD_i(31:0)" />
            <blockpin signalname="R_DO(31:0)" name="RD_i(31:0)" />
            <blockpin signalname="SDO(31:0)" name="SD_i(31:0)" />
            <blockpin signalname="CLK" name="CLK" />
            <blockpin signalname="ACK_N" name="MACK_N_o" />
            <blockpin signalname="RESET" name="RESET" />
            <blockpin signalname="Rsel" name="Rsel_o" />
            <blockpin signalname="sdCas_bo" name="sdCas_bo" />
            <blockpin signalname="sdCe_bo" name="sdCe_bo" />
            <blockpin signalname="sdCke_o" name="sdCke_o" />
            <blockpin signalname="sdClk_o" name="sdClk_o" />
            <blockpin signalname="sdDqmh_o" name="sdDqmh_o" />
            <blockpin signalname="sdDqml_o" name="sdDqml_o" />
            <blockpin signalname="sdRas_bo" name="sdRas_bo" />
            <blockpin signalname="sdWe_bo" name="sdWe_bo" />
            <blockpin signalname="Card_Sel" name="Ssel_o" />
            <blockpin signalname="STEP_EN" name="step_en_o" />
            <blockpin signalname="WR_IN_N" name="WR_N_o" />
            <blockpin signalname="AI(9:0)" name="A_o(9:0)" />
            <blockpin signalname="DO(31:0)" name="DO(31:0)" />
            <blockpin signalname="sdAddr_o(12:0)" name="sdAddr_o(12:0)" />
            <blockpin signalname="sdBs_o(1:0)" name="sdBs_o(1:0)" />
            <blockpin signalname="sdData_io(15:0)" name="sdData_io(15:0)" />
        </block>
        <block symbolname="monitor_salve" name="XLXI_30">
            <blockpin signalname="CLK" name="clk" />
            <blockpin signalname="IN_INIT" name="in_init" />
            <blockpin signalname="STEP_EN" name="step_en" />
            <blockpin signalname="STOP_N" name="stop_n" />
            <blockpin signalname="Card_Sel" name="CARD_SEL" />
            <blockpin signalname="WR_IN_N" name="WR_IN_N" />
            <blockpin signalname="AI(9:0)" name="AI(9:0)" />
            <blockpin signalname="D_IN(31:0)" name="D_IN(31:0)" />
            <blockpin signalname="D_RAM_OUT(31:0)" name="A_IN(31:0)" />
            <blockpin signalname="MAO(31:0)" name="B_IN(31:0)" />
            <blockpin signalname="SACK_N" name="SACK_N" />
            <blockpin signalname="SDO(31:0)" name="SDO(31:0)" />
            <blockpin signalname="reg_addr(4:0)" name="REG_ADDR(4:0)" />
        </block>
        <block symbolname="fd" name="XLXI_46">
            <blockpin signalname="CLK" name="C" />
            <blockpin signalname="AS_N" name="D" />
            <blockpin signalname="XLXN_1" name="Q" />
        </block>
        <block symbolname="or2" name="XLXI_47">
            <blockpin signalname="XLXN_1" name="I0" />
            <blockpin signalname="AS_N" name="I1" />
            <blockpin signalname="XLXN_2" name="O" />
        </block>
        <block symbolname="or2b1" name="XLXI_48">
            <blockpin signalname="ACK_N" name="I0" />
            <blockpin signalname="XLXN_2" name="I1" />
            <blockpin signalname="STOP_N" name="O" />
        </block>
        <block symbolname="DLX" name="XLXI_50">
            <blockpin signalname="CLK" name="clk" />
            <blockpin signalname="RESET" name="reset" />
            <blockpin signalname="STEP_EN" name="step_en" />
            <blockpin signalname="ACK_N" name="ack_n" />
            <blockpin signalname="DO(31:0)" name="D_in(31:0)" />
            <blockpin signalname="reg_addr(4:0)" name="Daddr(4:0)" />
            <blockpin signalname="D_IN(0)" name="busy" />
            <blockpin signalname="XLXN_76" name="MR" />
            <blockpin signalname="XLXN_77" name="MW" />
            <blockpin signalname="D_IN(3)" name="GPR_WE" />
            <blockpin signalname="D_IN(4)" name="IRCE" />
            <blockpin signalname="D_IN(5)" name="PCCE" />
            <blockpin signalname="D_IN(6)" name="ACE" />
            <blockpin signalname="D_IN(7)" name="BCE" />
            <blockpin signalname="D_IN(8)" name="CCE" />
            <blockpin signalname="D_IN(9)" name="MDRCE" />
            <blockpin signalname="D_IN(10)" name="DINTSEL" />
            <blockpin signalname="D_IN(11)" name="MDRSEL" />
            <blockpin signalname="D_IN(12)" name="ASEL" />
            <blockpin signalname="D_IN(13)" name="ADD" />
            <blockpin signalname="D_IN(14)" name="TEST" />
            <blockpin signalname="D_IN(15)" name="SHIFT" />
            <blockpin signalname="D_IN(19)" name="ITYPE" />
            <blockpin signalname="D_IN(16)" name="JLINK" />
            <blockpin signalname="D_IN(17)" name="MARCE" />
            <blockpin signalname="D_IN(18)" name="RIGHT" />
            <blockpin signalname="IN_INIT" name="in_init" />
            <blockpin signalname="D_IN(24:23)" name="mac_state(1:0)" />
            <blockpin signalname="D_IN(29:25)" name="control_state(4:0)" />
            <blockpin signalname="D_IN(31:30)" name="S1SEL(1:0)" />
            <blockpin signalname="D_IN(2:1)" name="S2SEL(1:0)" />
            <blockpin signalname="D_RAM_OUT(31:0)" name="D_OUT_GPR(31:0)" />
            <blockpin signalname="WR_OUT_N" name="wr_n_new" />
            <blockpin signalname="AS_N" name="as_n_new" />
            <blockpin signalname="MAO(31:0)" name="AO_new(31:0)" />
            <blockpin signalname="MDO(31:0)" name="DO_new(31:0)" />
        </block>
        <block symbolname="buf" name="XLXI_51">
            <blockpin signalname="AS_N" name="I" />
            <blockpin signalname="D_IN(20)" name="O" />
        </block>
        <block symbolname="buf" name="XLXI_52">
            <blockpin signalname="WR_OUT_N" name="I" />
            <blockpin signalname="D_IN(21)" name="O" />
        </block>
        <block symbolname="buf" name="XLXI_53">
            <blockpin signalname="IN_INIT" name="I" />
            <blockpin signalname="D_IN(22)" name="O" />
        </block>
    </netlist>
    <sheet sheetnum="1" width="3520" height="2720">
        <branch name="AS_N">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="240" y="208" type="branch" />
            <wire x2="432" y1="208" y2="208" x1="240" />
        </branch>
        <branch name="WR_OUT_N">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="240" y="256" type="branch" />
            <wire x2="528" y1="256" y2="256" x1="240" />
        </branch>
        <branch name="MAO(31:0)">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="240" y="304" type="branch" />
            <wire x2="432" y1="304" y2="304" x1="240" />
        </branch>
        <branch name="MDO(31:0)">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="240" y="352" type="branch" />
            <wire x2="432" y1="352" y2="352" x1="240" />
        </branch>
        <branch name="ACK_N">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="240" y="400" type="branch" />
            <wire x2="432" y1="400" y2="400" x1="240" />
        </branch>
        <branch name="Card_Sel">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="240" y="2080" type="branch" />
            <wire x2="448" y1="2080" y2="2080" x1="240" />
        </branch>
        <branch name="AI(9:0)">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="240" y="2032" type="branch" />
            <wire x2="448" y1="2032" y2="2032" x1="240" />
        </branch>
        <branch name="WR_IN_N">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="240" y="1984" type="branch" />
            <wire x2="448" y1="1984" y2="1984" x1="240" />
        </branch>
        <branch name="SDO(31:0)">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="240" y="1936" type="branch" />
            <wire x2="448" y1="1936" y2="1936" x1="240" />
        </branch>
        <branch name="SACK_N">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="240" y="1888" type="branch" />
            <wire x2="448" y1="1888" y2="1888" x1="240" />
        </branch>
        <branch name="DO(31:0)">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="240" y="1632" type="branch" />
            <wire x2="448" y1="1632" y2="1632" x1="240" />
        </branch>
        <branch name="IN_INIT">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="256" y="1024" type="branch" />
            <wire x2="448" y1="1024" y2="1024" x1="256" />
        </branch>
        <branch name="RESET">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="256" y="1072" type="branch" />
            <wire x2="448" y1="1072" y2="1072" x1="256" />
        </branch>
        <branch name="STEP_EN">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="256" y="1120" type="branch" />
            <wire x2="448" y1="1120" y2="1120" x1="256" />
        </branch>
        <branch name="CLK">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="256" y="1168" type="branch" />
            <wire x2="448" y1="1168" y2="1168" x1="256" />
        </branch>
        <text style="fontsize:32;fontname:Arial" x="268" y="488">Master I/O</text>
        <text style="fontsize:32;fontname:Arial" x="284" y="1232">Control I/O</text>
        <text style="fontsize:32;fontname:Arial" x="256" y="1692">Bus data O</text>
        <text style="fontsize:32;fontname:Arial" x="280" y="2140">Slave I/O</text>
        <instance x="1392" y="1552" name="XLXI_30" orien="R0">
        </instance>
        <branch name="CLK">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="1312" y="944" type="branch" />
            <wire x2="1392" y1="944" y2="944" x1="1312" />
        </branch>
        <branch name="IN_INIT">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="1312" y="1008" type="branch" />
            <wire x2="1392" y1="1008" y2="1008" x1="1312" />
        </branch>
        <branch name="STEP_EN">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="1312" y="1072" type="branch" />
            <wire x2="1392" y1="1072" y2="1072" x1="1312" />
        </branch>
        <branch name="Card_Sel">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="1312" y="1200" type="branch" />
            <wire x2="1392" y1="1200" y2="1200" x1="1312" />
        </branch>
        <branch name="WR_IN_N">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="1296" y="1264" type="branch" />
            <wire x2="1392" y1="1264" y2="1264" x1="1296" />
        </branch>
        <branch name="AI(9:0)">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="1280" y="1328" type="branch" />
            <wire x2="1392" y1="1328" y2="1328" x1="1280" />
        </branch>
        <branch name="D_IN(31:0)">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="1280" y="1392" type="branch" />
            <wire x2="1392" y1="1392" y2="1392" x1="1280" />
        </branch>
        <branch name="D_RAM_OUT(31:0)">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="1280" y="1456" type="branch" />
            <wire x2="1296" y1="1456" y2="1456" x1="1280" />
            <wire x2="1392" y1="1456" y2="1456" x1="1296" />
        </branch>
        <branch name="MAO(31:0)">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="1296" y="1520" type="branch" />
            <wire x2="1392" y1="1520" y2="1520" x1="1296" />
        </branch>
        <branch name="SACK_N">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="1904" y="944" type="branch" />
            <wire x2="1856" y1="944" y2="944" x1="1840" />
            <wire x2="1904" y1="944" y2="944" x1="1856" />
        </branch>
        <branch name="SDO(31:0)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="1920" y="1232" type="branch" />
            <wire x2="1920" y1="1232" y2="1232" x1="1840" />
        </branch>
        <branch name="reg_addr(4:0)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="1920" y="1520" type="branch" />
            <wire x2="1920" y1="1520" y2="1520" x1="1840" />
        </branch>
        <branch name="STOP_N">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="1296" y="1136" type="branch" />
            <wire x2="1392" y1="1136" y2="1136" x1="1296" />
        </branch>
        <instance x="1488" y="2480" name="XLXI_46" orien="R0" />
        <instance x="1952" y="2288" name="XLXI_47" orien="R0" />
        <instance x="2320" y="2320" name="XLXI_48" orien="R0" />
        <branch name="XLXN_1">
            <wire x2="1952" y1="2224" y2="2224" x1="1872" />
        </branch>
        <branch name="XLXN_2">
            <wire x2="2320" y1="2192" y2="2192" x1="2208" />
        </branch>
        <branch name="AS_N">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="1872" y="2064" type="branch" />
            <wire x2="1904" y1="2064" y2="2064" x1="1872" />
            <wire x2="1904" y1="2064" y2="2160" x1="1904" />
            <wire x2="1952" y1="2160" y2="2160" x1="1904" />
        </branch>
        <branch name="AS_N">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="1376" y="2224" type="branch" />
            <wire x2="1488" y1="2224" y2="2224" x1="1376" />
        </branch>
        <branch name="CLK">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="1376" y="2352" type="branch" />
            <wire x2="1488" y1="2352" y2="2352" x1="1376" />
        </branch>
        <branch name="ACK_N">
            <attrtext style="alignment:SOFT-VRIGHT;fontsize:28;fontname:Arial" attrname="Name" x="2208" y="2336" type="branch" />
            <wire x2="2320" y1="2256" y2="2256" x1="2208" />
            <wire x2="2208" y1="2256" y2="2336" x1="2208" />
        </branch>
        <branch name="STOP_N">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="2720" y="2224" type="branch" />
            <wire x2="2720" y1="2224" y2="2224" x1="2576" />
        </branch>
        <instance x="2800" y="1968" name="XLXI_50" orien="R0">
        </instance>
        <branch name="CLK">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="2736" y="80" type="branch" />
            <wire x2="2800" y1="80" y2="80" x1="2736" />
        </branch>
        <branch name="RESET">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="2752" y="448" type="branch" />
            <wire x2="2800" y1="448" y2="448" x1="2752" />
        </branch>
        <branch name="STEP_EN">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="2768" y="816" type="branch" />
            <wire x2="2800" y1="816" y2="816" x1="2768" />
        </branch>
        <branch name="ACK_N">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="2752" y="1184" type="branch" />
            <wire x2="2800" y1="1184" y2="1184" x1="2752" />
        </branch>
        <branch name="DO(31:0)">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="2768" y="1552" type="branch" />
            <wire x2="2800" y1="1552" y2="1552" x1="2768" />
        </branch>
        <branch name="reg_addr(4:0)">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="2768" y="1920" type="branch" />
            <wire x2="2800" y1="1920" y2="1920" x1="2768" />
        </branch>
        <branch name="MDO(31:0)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="3312" y="2256" type="branch" />
            <wire x2="3312" y1="2256" y2="2256" x1="3264" />
        </branch>
        <branch name="MAO(31:0)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="3312" y="2192" type="branch" />
            <wire x2="3312" y1="2192" y2="2192" x1="3264" />
        </branch>
        <branch name="AS_N">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="3312" y="2128" type="branch" />
            <wire x2="3312" y1="2128" y2="2128" x1="3264" />
        </branch>
        <branch name="WR_OUT_N">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="3312" y="2064" type="branch" />
            <wire x2="3312" y1="2064" y2="2064" x1="3264" />
        </branch>
        <branch name="D_IN(19)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="3312" y="2000" type="branch" />
            <wire x2="3312" y1="2000" y2="2000" x1="3264" />
        </branch>
        <branch name="D_RAM_OUT(31:0)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="3312" y="1936" type="branch" />
            <wire x2="3312" y1="1936" y2="1936" x1="3264" />
        </branch>
        <branch name="D_IN(2:1)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="3344" y="1744" type="branch" />
            <wire x2="3344" y1="1744" y2="1744" x1="3264" />
        </branch>
        <branch name="D_IN(31:30)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="3344" y="1680" type="branch" />
            <wire x2="3344" y1="1680" y2="1680" x1="3264" />
        </branch>
        <branch name="D_IN(29:25)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="3344" y="1616" type="branch" />
            <wire x2="3344" y1="1616" y2="1616" x1="3264" />
        </branch>
        <branch name="D_IN(24:23)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="3344" y="1552" type="branch" />
            <wire x2="3344" y1="1552" y2="1552" x1="3264" />
        </branch>
        <branch name="IN_INIT">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="3328" y="1488" type="branch" />
            <wire x2="3328" y1="1488" y2="1488" x1="3264" />
        </branch>
        <branch name="D_IN(18)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="3328" y="1424" type="branch" />
            <wire x2="3328" y1="1424" y2="1424" x1="3264" />
        </branch>
        <branch name="D_IN(17)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="3328" y="1360" type="branch" />
            <wire x2="3328" y1="1360" y2="1360" x1="3264" />
        </branch>
        <branch name="D_IN(16)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="3328" y="1296" type="branch" />
            <wire x2="3328" y1="1296" y2="1296" x1="3264" />
        </branch>
        <branch name="D_IN(15)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="3312" y="1168" type="branch" />
            <wire x2="3312" y1="1168" y2="1168" x1="3264" />
        </branch>
        <branch name="D_IN(14)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="3328" y="1104" type="branch" />
            <wire x2="3328" y1="1104" y2="1104" x1="3264" />
        </branch>
        <branch name="D_IN(13)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="3328" y="1040" type="branch" />
            <wire x2="3328" y1="1040" y2="1040" x1="3264" />
        </branch>
        <branch name="D_IN(12)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="3328" y="976" type="branch" />
            <wire x2="3328" y1="976" y2="976" x1="3264" />
        </branch>
        <branch name="D_IN(11)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="3328" y="912" type="branch" />
            <wire x2="3328" y1="912" y2="912" x1="3264" />
        </branch>
        <branch name="D_IN(10)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="3328" y="848" type="branch" />
            <wire x2="3328" y1="848" y2="848" x1="3264" />
        </branch>
        <branch name="D_IN(9)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="3296" y="784" type="branch" />
            <wire x2="3296" y1="784" y2="784" x1="3264" />
        </branch>
        <branch name="D_IN(0)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="3296" y="80" type="branch" />
            <wire x2="3296" y1="80" y2="80" x1="3264" />
        </branch>
        <branch name="XLXN_76">
            <wire x2="3312" y1="272" y2="272" x1="3264" />
        </branch>
        <branch name="XLXN_77">
            <wire x2="3312" y1="336" y2="336" x1="3264" />
        </branch>
        <branch name="D_IN(3)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="3312" y="400" type="branch" />
            <wire x2="3312" y1="400" y2="400" x1="3264" />
        </branch>
        <branch name="D_IN(4)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="3296" y="464" type="branch" />
            <wire x2="3296" y1="464" y2="464" x1="3264" />
        </branch>
        <branch name="D_IN(5)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="3312" y="528" type="branch" />
            <wire x2="3312" y1="528" y2="528" x1="3264" />
        </branch>
        <branch name="D_IN(6)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="3328" y="592" type="branch" />
            <wire x2="3328" y1="592" y2="592" x1="3264" />
        </branch>
        <branch name="D_IN(7)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="3312" y="656" type="branch" />
            <wire x2="3312" y1="656" y2="656" x1="3264" />
        </branch>
        <branch name="D_IN(8)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="3312" y="720" type="branch" />
            <wire x2="3312" y1="720" y2="720" x1="3264" />
        </branch>
        <instance x="1264" y="256" name="XLXI_51" orien="R0" />
        <instance x="1264" y="368" name="XLXI_52" orien="R0" />
        <instance x="1264" y="480" name="XLXI_53" orien="R0" />
        <branch name="D_IN(20)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="1552" y="224" type="branch" />
            <wire x2="1552" y1="224" y2="224" x1="1488" />
        </branch>
        <branch name="D_IN(21)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="1552" y="336" type="branch" />
            <wire x2="1552" y1="336" y2="336" x1="1488" />
        </branch>
        <branch name="D_IN(22)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="1552" y="448" type="branch" />
            <wire x2="1552" y1="448" y2="448" x1="1488" />
        </branch>
        <branch name="AS_N">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="1200" y="224" type="branch" />
            <wire x2="1264" y1="224" y2="224" x1="1200" />
        </branch>
        <branch name="WR_OUT_N">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="1200" y="336" type="branch" />
            <wire x2="1264" y1="336" y2="336" x1="1200" />
        </branch>
        <branch name="IN_INIT">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="1184" y="448" type="branch" />
            <wire x2="1264" y1="448" y2="448" x1="1184" />
        </branch>
    </sheet>
    <sheet sheetnum="2" width="3520" height="2720">
        <branch name="DO(31:0)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="2240" y="1632" type="branch" />
            <wire x2="2240" y1="1632" y2="1632" x1="1840" />
        </branch>
        <branch name="AI(9:0)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="2240" y="1568" type="branch" />
            <wire x2="2240" y1="1568" y2="1568" x1="1840" />
        </branch>
        <branch name="sdClk_o">
            <wire x2="1856" y1="1056" y2="1056" x1="1840" />
            <wire x2="1904" y1="1056" y2="1056" x1="1856" />
        </branch>
        <branch name="sdBs_o(1:0)">
            <wire x2="1856" y1="1760" y2="1760" x1="1840" />
            <wire x2="1904" y1="1760" y2="1760" x1="1856" />
        </branch>
        <branch name="sdDqml_o">
            <wire x2="1856" y1="1184" y2="1184" x1="1840" />
            <wire x2="1904" y1="1184" y2="1184" x1="1856" />
        </branch>
        <branch name="sdDqmh_o">
            <wire x2="1856" y1="1120" y2="1120" x1="1840" />
            <wire x2="1904" y1="1120" y2="1120" x1="1856" />
        </branch>
        <branch name="sdWe_bo">
            <wire x2="1856" y1="1312" y2="1312" x1="1840" />
            <wire x2="1904" y1="1312" y2="1312" x1="1856" />
        </branch>
        <branch name="sdCas_bo">
            <wire x2="1856" y1="864" y2="864" x1="1840" />
            <wire x2="1888" y1="864" y2="864" x1="1856" />
        </branch>
        <branch name="sdRas_bo">
            <wire x2="1856" y1="1248" y2="1248" x1="1840" />
            <wire x2="1904" y1="1248" y2="1248" x1="1856" />
        </branch>
        <branch name="sdCe_bo">
            <wire x2="1856" y1="928" y2="928" x1="1840" />
            <wire x2="1888" y1="928" y2="928" x1="1856" />
        </branch>
        <branch name="sdCke_o">
            <wire x2="1856" y1="992" y2="992" x1="1840" />
            <wire x2="1888" y1="992" y2="992" x1="1856" />
        </branch>
        <branch name="IN_INIT">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="1360" y="832" type="branch" />
            <wire x2="1408" y1="832" y2="832" x1="1360" />
        </branch>
        <branch name="fpgaClk_i">
            <wire x2="1408" y1="720" y2="720" x1="1376" />
        </branch>
        <branch name="MAO(31:0)">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="1344" y="1392" type="branch" />
            <wire x2="1408" y1="1392" y2="1392" x1="1344" />
        </branch>
        <branch name="R_DO(31:0)">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="1328" y="1616" type="branch" />
            <wire x2="1408" y1="1616" y2="1616" x1="1328" />
        </branch>
        <instance x="1408" y="1856" name="XLXI_23" orien="R0">
        </instance>
        <branch name="AS_N">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="1360" y="608" type="branch" />
            <wire x2="1408" y1="608" y2="608" x1="1360" />
        </branch>
        <branch name="WR_OUT_N">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="1344" y="1280" type="branch" />
            <wire x2="1408" y1="1280" y2="1280" x1="1344" />
        </branch>
        <branch name="RACK_N">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="1360" y="944" type="branch" />
            <wire x2="1408" y1="944" y2="944" x1="1360" />
        </branch>
        <branch name="SACK_N">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="1344" y="1056" type="branch" />
            <wire x2="1408" y1="1056" y2="1056" x1="1344" />
        </branch>
        <branch name="MDO(31:0)">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="1344" y="1504" type="branch" />
            <wire x2="1408" y1="1504" y2="1504" x1="1344" />
        </branch>
        <branch name="SDO(31:0)">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="1344" y="1728" type="branch" />
            <wire x2="1408" y1="1728" y2="1728" x1="1344" />
        </branch>
        <branch name="sdClkFb_i">
            <wire x2="1408" y1="1168" y2="1168" x1="1360" />
        </branch>
        <iomarker fontsize="28" x="1360" y="1168" name="sdClkFb_i" orien="R180" />
        <iomarker fontsize="28" x="1376" y="720" name="fpgaClk_i" orien="R180" />
        <branch name="RESET">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="1904" y="736" type="branch" />
            <wire x2="1904" y1="736" y2="736" x1="1840" />
        </branch>
        <branch name="CLK">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="1904" y="608" type="branch" />
            <wire x2="1904" y1="608" y2="608" x1="1840" />
        </branch>
        <branch name="STEP_EN">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="1920" y="1440" type="branch" />
            <wire x2="1920" y1="1440" y2="1440" x1="1840" />
        </branch>
        <branch name="WR_IN_N">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="1936" y="1504" type="branch" />
            <wire x2="1936" y1="1504" y2="1504" x1="1840" />
        </branch>
        <branch name="ACK_N">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="1936" y="672" type="branch" />
            <wire x2="1936" y1="672" y2="672" x1="1840" />
        </branch>
        <branch name="Rsel">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="1936" y="800" type="branch" />
            <wire x2="1936" y1="800" y2="800" x1="1840" />
        </branch>
        <branch name="Card_Sel">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="1936" y="1376" type="branch" />
            <wire x2="1936" y1="1376" y2="1376" x1="1840" />
        </branch>
        <branch name="sdData_io(15:0)">
            <wire x2="1856" y1="1824" y2="1824" x1="1840" />
            <wire x2="1904" y1="1824" y2="1824" x1="1856" />
        </branch>
        <branch name="sdAddr_o(12:0)">
            <wire x2="1904" y1="1696" y2="1696" x1="1840" />
        </branch>
        <iomarker fontsize="28" x="1904" y="1696" name="sdAddr_o(12:0)" orien="R0" />
        <iomarker fontsize="28" x="1904" y="1824" name="sdData_io(15:0)" orien="R0" />
        <iomarker fontsize="28" x="1904" y="1056" name="sdClk_o" orien="R0" />
        <iomarker fontsize="28" x="1888" y="864" name="sdCas_bo" orien="R0" />
        <iomarker fontsize="28" x="1888" y="928" name="sdCe_bo" orien="R0" />
        <iomarker fontsize="28" x="1888" y="992" name="sdCke_o" orien="R0" />
        <iomarker fontsize="28" x="1904" y="1184" name="sdDqml_o" orien="R0" />
        <iomarker fontsize="28" x="1904" y="1120" name="sdDqmh_o" orien="R0" />
        <iomarker fontsize="28" x="1904" y="1312" name="sdWe_bo" orien="R0" />
        <iomarker fontsize="28" x="1904" y="1248" name="sdRas_bo" orien="R0" />
        <iomarker fontsize="28" x="1904" y="1760" name="sdBs_o(1:0)" orien="R0" />
    </sheet>
</drawing>