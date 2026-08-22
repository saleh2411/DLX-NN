<?xml version="1.0" encoding="UTF-8"?>
<drawing version="7">
    <attr value="spartan6" name="DeviceFamilyName">
        <trait delete="all:0" />
        <trait editname="all:0" />
        <trait edittrait="all:0" />
    </attr>
    <netlist>
        <signal name="CLK" />
        <signal name="STEP_EN" />
        <signal name="RESET" />
        <signal name="XLXN_9" />
        <signal name="wide(31:0)" />
        <signal name="reg_out(31:0)" />
        <signal name="wide(4:0)" />
        <signal name="reg_adr(4:0)" />
        <signal name="step_num(4:0)" />
        <signal name="state(3:0)" />
        <signal name="reg_write(4:0)" />
        <signal name="in_init" />
        <signal name="state(3)" />
        <signal name="Data(4:0)" />
        <port polarity="Input" name="CLK" />
        <port polarity="Input" name="STEP_EN" />
        <port polarity="Input" name="RESET" />
        <port polarity="Output" name="reg_out(31:0)" />
        <port polarity="Input" name="reg_adr(4:0)" />
        <port polarity="Output" name="step_num(4:0)" />
        <port polarity="Output" name="state(3:0)" />
        <port polarity="Output" name="reg_write(4:0)" />
        <port polarity="Output" name="in_init" />
        <blockdef name="BROJA">
            <timestamp>2009-7-28T7:20:44</timestamp>
            <rect width="64" x="320" y="20" height="24" />
            <line x2="384" y1="32" y2="32" x1="320" />
            <line x2="0" y1="-160" y2="-160" x1="64" />
            <line x2="0" y1="-96" y2="-96" x1="64" />
            <line x2="0" y1="-32" y2="-32" x1="64" />
            <line x2="384" y1="-160" y2="-160" x1="320" />
            <line x2="384" y1="-32" y2="-32" x1="320" />
            <rect width="64" x="320" y="-44" height="24" />
            <rect width="256" x="64" y="-192" height="256" />
        </blockdef>
        <blockdef name="inv">
            <timestamp>2000-1-1T10:10:10</timestamp>
            <line x2="64" y1="-32" y2="-32" x1="0" />
            <line x2="160" y1="-32" y2="-32" x1="224" />
            <line x2="128" y1="-64" y2="-32" x1="64" />
            <line x2="64" y1="-32" y2="0" x1="128" />
            <line x2="64" y1="0" y2="-64" x1="64" />
            <circle r="16" cx="144" cy="-32" />
        </blockdef>
        <blockdef name="RAM32x32">
            <timestamp>2024-4-13T10:58:1</timestamp>
            <rect width="256" x="64" y="-256" height="256" />
            <line x2="0" y1="-224" y2="-224" x1="64" />
            <line x2="0" y1="-160" y2="-160" x1="64" />
            <rect width="64" x="0" y="-108" height="24" />
            <line x2="0" y1="-96" y2="-96" x1="64" />
            <rect width="64" x="0" y="-44" height="24" />
            <line x2="0" y1="-32" y2="-32" x1="64" />
            <rect width="64" x="320" y="-236" height="24" />
            <line x2="384" y1="-224" y2="-224" x1="320" />
        </blockdef>
        <blockdef name="Step_CNT5">
            <timestamp>2024-4-13T11:13:55</timestamp>
            <rect width="256" x="64" y="-192" height="192" />
            <line x2="0" y1="-160" y2="-160" x1="64" />
            <line x2="0" y1="-96" y2="-96" x1="64" />
            <line x2="0" y1="-32" y2="-32" x1="64" />
            <rect width="64" x="320" y="-172" height="24" />
            <line x2="384" y1="-160" y2="-160" x1="320" />
        </blockdef>
        <blockdef name="MUX5bit">
            <timestamp>2024-4-13T11:19:18</timestamp>
            <rect width="256" x="64" y="-192" height="192" />
            <line x2="0" y1="-160" y2="-160" x1="64" />
            <rect width="64" x="0" y="-108" height="24" />
            <line x2="0" y1="-96" y2="-96" x1="64" />
            <rect width="64" x="0" y="-44" height="24" />
            <line x2="0" y1="-32" y2="-32" x1="64" />
            <rect width="64" x="320" y="-172" height="24" />
            <line x2="384" y1="-160" y2="-160" x1="320" />
        </blockdef>
        <blockdef name="BUF5">
            <timestamp>2024-4-13T11:45:23</timestamp>
            <rect width="256" x="64" y="-64" height="64" />
            <rect width="64" x="0" y="-44" height="24" />
            <line x2="0" y1="-32" y2="-32" x1="64" />
            <rect width="64" x="320" y="-44" height="24" />
            <line x2="384" y1="-32" y2="-32" x1="320" />
        </blockdef>
        <block symbolname="inv" name="XLXI_2">
            <blockpin signalname="state(3)" name="I" />
            <blockpin signalname="XLXN_9" name="O" />
        </block>
        <block symbolname="BROJA" name="XLXI_1">
            <blockpin signalname="CLK" name="clk" />
            <blockpin signalname="STEP_EN" name="step" />
            <blockpin signalname="RESET" name="reset" />
            <blockpin signalname="in_init" name="in_init" />
            <blockpin signalname="wide(31:0)" name="cnt(31:0)" />
            <blockpin signalname="state(3:0)" name="state(3:0)" />
        </block>
        <block symbolname="RAM32x32" name="XLXI_9">
            <blockpin signalname="CLK" name="CLK" />
            <blockpin signalname="XLXN_9" name="WE" />
            <blockpin signalname="Data(4:0)" name="ADDR(4:0)" />
            <blockpin signalname="wide(31:0)" name="DI(31:0)" />
            <blockpin signalname="reg_out(31:0)" name="DO(31:0)" />
        </block>
        <block symbolname="MUX5bit" name="XLXI_12">
            <blockpin signalname="state(3)" name="sel" />
            <blockpin signalname="wide(4:0)" name="A(4:0)" />
            <blockpin signalname="reg_adr(4:0)" name="B(4:0)" />
            <blockpin signalname="Data(4:0)" name="O(4:0)" />
        </block>
        <block symbolname="BUF5" name="XLXI_13">
            <blockpin signalname="wide(4:0)" name="I(4:0)" />
            <blockpin signalname="reg_write(4:0)" name="O(4:0)" />
        </block>
        <block symbolname="Step_CNT5" name="XLXI_10">
            <blockpin signalname="CLK" name="CLK" />
            <blockpin signalname="RESET" name="RST" />
            <blockpin signalname="STEP_EN" name="CE" />
            <blockpin signalname="step_num(4:0)" name="CNT(4:0)" />
        </block>
    </netlist>
    <sheet sheetnum="1" width="3520" height="2720">
        <branch name="CLK">
            <attrtext style="alignment:SOFT-RIGHT" attrname="Name" x="1696" y="1632" type="branch" />
            <wire x2="1760" y1="1632" y2="1632" x1="1696" />
        </branch>
        <instance x="1152" y="1120" name="XLXI_1" orien="R0">
        </instance>
        <branch name="CLK">
            <attrtext style="alignment:SOFT-RIGHT" attrname="Name" x="2272" y="896" type="branch" />
            <wire x2="2320" y1="896" y2="896" x1="2272" />
        </branch>
        <branch name="wide(31:0)">
            <attrtext style="alignment:SOFT-BCENTER" attrname="Name" x="1808" y="1088" type="branch" />
            <wire x2="1808" y1="1088" y2="1088" x1="1536" />
            <wire x2="2320" y1="1088" y2="1088" x1="1808" />
        </branch>
        <branch name="reg_out(31:0)">
            <wire x2="2832" y1="896" y2="896" x1="2704" />
        </branch>
        <branch name="wide(4:0)">
            <attrtext style="alignment:SOFT-RIGHT" attrname="Name" x="1680" y="1392" type="branch" />
            <wire x2="1760" y1="1392" y2="1392" x1="1680" />
        </branch>
        <branch name="reg_adr(4:0)">
            <wire x2="1760" y1="1456" y2="1456" x1="1072" />
        </branch>
        <branch name="CLK">
            <wire x2="1152" y1="960" y2="960" x1="464" />
        </branch>
        <branch name="STEP_EN">
            <wire x2="1152" y1="1024" y2="1024" x1="464" />
        </branch>
        <branch name="RESET">
            <wire x2="1152" y1="1088" y2="1088" x1="464" />
        </branch>
        <branch name="step_num(4:0)">
            <wire x2="2768" y1="1632" y2="1632" x1="2144" />
        </branch>
        <branch name="state(3:0)">
            <wire x2="2864" y1="1152" y2="1152" x1="1536" />
        </branch>
        <branch name="wide(4:0)">
            <attrtext style="alignment:SOFT-RIGHT" attrname="Name" x="2160" y="1904" type="branch" />
            <wire x2="2256" y1="1904" y2="1904" x1="2160" />
        </branch>
        <branch name="reg_write(4:0)">
            <wire x2="2752" y1="1904" y2="1904" x1="2640" />
        </branch>
        <branch name="in_init">
            <wire x2="1680" y1="960" y2="960" x1="1536" />
            <wire x2="2752" y1="656" y2="656" x1="1680" />
            <wire x2="1680" y1="656" y2="960" x1="1680" />
        </branch>
        <iomarker fontsize="28" x="2832" y="896" name="reg_out(31:0)" orien="R0" />
        <iomarker fontsize="28" x="2752" y="656" name="in_init" orien="R0" />
        <iomarker fontsize="28" x="464" y="960" name="CLK" orien="R180" />
        <iomarker fontsize="28" x="464" y="1024" name="STEP_EN" orien="R180" />
        <iomarker fontsize="28" x="464" y="1088" name="RESET" orien="R180" />
        <iomarker fontsize="28" x="2864" y="1152" name="state(3:0)" orien="R0" />
        <iomarker fontsize="28" x="2768" y="1632" name="step_num(4:0)" orien="R0" />
        <iomarker fontsize="28" x="2752" y="1904" name="reg_write(4:0)" orien="R0" />
        <iomarker fontsize="28" x="1072" y="1456" name="reg_adr(4:0)" orien="R180" />
        <branch name="state(3)">
            <attrtext style="alignment:SOFT-RIGHT" attrname="Name" x="1664" y="1328" type="branch" />
            <wire x2="1744" y1="1328" y2="1328" x1="1664" />
            <wire x2="1760" y1="1328" y2="1328" x1="1744" />
            <wire x2="1744" y1="960" y2="1328" x1="1744" />
            <wire x2="1984" y1="960" y2="960" x1="1744" />
        </branch>
        <instance x="1984" y="992" name="XLXI_2" orien="R0" />
        <branch name="XLXN_9">
            <wire x2="2320" y1="960" y2="960" x1="2208" />
        </branch>
        <instance x="2320" y="1120" name="XLXI_9" orien="R0">
        </instance>
        <branch name="Data(4:0)">
            <wire x2="2240" y1="1328" y2="1328" x1="2144" />
            <wire x2="2320" y1="1024" y2="1024" x1="2240" />
            <wire x2="2240" y1="1024" y2="1328" x1="2240" />
        </branch>
        <instance x="1760" y="1488" name="XLXI_12" orien="R0">
        </instance>
        <instance x="2256" y="1936" name="XLXI_13" orien="R0">
        </instance>
        <instance x="1760" y="1792" name="XLXI_10" orien="R0">
        </instance>
        <branch name="STEP_EN">
            <attrtext style="alignment:SOFT-RIGHT" attrname="Name" x="1696" y="1760" type="branch" />
            <wire x2="1760" y1="1760" y2="1760" x1="1696" />
        </branch>
        <branch name="RESET">
            <attrtext style="alignment:SOFT-RIGHT" attrname="Name" x="1696" y="1696" type="branch" />
            <wire x2="1760" y1="1696" y2="1696" x1="1696" />
        </branch>
    </sheet>
</drawing>