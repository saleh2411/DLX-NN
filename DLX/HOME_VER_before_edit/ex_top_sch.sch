<?xml version="1.0" encoding="UTF-8"?>
<drawing version="7">
    <attr value="spartan6" name="DeviceFamilyName">
        <trait delete="all:0" />
        <trait editname="all:0" />
        <trait edittrait="all:0" />
    </attr>
    <netlist>
        <signal name="reset" />
        <signal name="clock" />
        <signal name="ce_reg1" />
        <signal name="ce_reg2" />
        <signal name="data_in1(15:0)" />
        <signal name="data_in2(15:0)" />
        <signal name="mux_sel" />
        <signal name="buf_en1" />
        <signal name="buf_en2" />
        <signal name="data_out1(15:0)" />
        <signal name="data_out2(15:0)" />
        <signal name="XLXN_28(15:0)" />
        <signal name="XLXN_29(15:0)" />
        <signal name="XLXN_32" />
        <signal name="XLXN_33" />
        <signal name="data_mux_out(15:0)" />
        <signal name="data_buf_out(15:0)" />
        <port polarity="Input" name="reset" />
        <port polarity="Input" name="clock" />
        <port polarity="Input" name="ce_reg1" />
        <port polarity="Input" name="ce_reg2" />
        <port polarity="Input" name="data_in1(15:0)" />
        <port polarity="Input" name="data_in2(15:0)" />
        <port polarity="Input" name="mux_sel" />
        <port polarity="Input" name="buf_en1" />
        <port polarity="Input" name="buf_en2" />
        <port polarity="Output" name="data_mux_out(15:0)" />
        <port polarity="Output" name="data_buf_out(15:0)" />
        <blockdef name="ex_reg_ver">
            <timestamp>2024-11-5T11:1:21</timestamp>
            <rect width="304" x="64" y="-256" height="256" />
            <line x2="0" y1="-224" y2="-224" x1="64" />
            <line x2="0" y1="-160" y2="-160" x1="64" />
            <line x2="0" y1="-96" y2="-96" x1="64" />
            <rect width="64" x="0" y="-44" height="24" />
            <line x2="0" y1="-32" y2="-32" x1="64" />
            <rect width="64" x="368" y="-236" height="24" />
            <line x2="432" y1="-224" y2="-224" x1="368" />
        </blockdef>
        <blockdef name="ex_mux_ver">
            <timestamp>2024-11-5T11:18:33</timestamp>
            <rect width="320" x="64" y="-192" height="192" />
            <line x2="0" y1="-160" y2="-160" x1="64" />
            <rect width="64" x="0" y="-108" height="24" />
            <line x2="0" y1="-96" y2="-96" x1="64" />
            <rect width="64" x="0" y="-44" height="24" />
            <line x2="0" y1="-32" y2="-32" x1="64" />
            <rect width="64" x="384" y="-172" height="24" />
            <line x2="448" y1="-160" y2="-160" x1="384" />
        </blockdef>
        <blockdef name="ex_buf_ver">
            <timestamp>2024-11-5T11:26:28</timestamp>
            <rect width="256" x="64" y="-128" height="128" />
            <line x2="0" y1="-96" y2="-96" x1="64" />
            <rect width="64" x="0" y="-44" height="24" />
            <line x2="0" y1="-32" y2="-32" x1="64" />
            <rect width="64" x="320" y="-108" height="24" />
            <line x2="384" y1="-96" y2="-96" x1="320" />
        </blockdef>
        <block symbolname="ex_buf_ver" name="XLXI_5">
            <blockpin signalname="buf_en2" name="buf_en" />
            <blockpin signalname="data_out2(15:0)" name="buf_in(15:0)" />
            <blockpin signalname="data_buf_out(15:0)" name="buf_out(15:0)" />
        </block>
        <block symbolname="ex_buf_ver" name="XLXI_4">
            <blockpin signalname="buf_en1" name="buf_en" />
            <blockpin signalname="data_out1(15:0)" name="buf_in(15:0)" />
            <blockpin signalname="data_buf_out(15:0)" name="buf_out(15:0)" />
        </block>
        <block symbolname="ex_mux_ver" name="XLXI_3">
            <blockpin signalname="mux_sel" name="mux_sel" />
            <blockpin signalname="data_out1(15:0)" name="mux_in_a(15:0)" />
            <blockpin signalname="data_out2(15:0)" name="mux_in_b(15:0)" />
            <blockpin signalname="data_mux_out(15:0)" name="mux_out(15:0)" />
        </block>
        <block symbolname="ex_reg_ver" name="XLXI_2">
            <blockpin signalname="reset" name="reset" />
            <blockpin signalname="clock" name="clock" />
            <blockpin signalname="ce_reg2" name="ce_reg" />
            <blockpin signalname="data_in2(15:0)" name="data_in(15:0)" />
            <blockpin signalname="data_out2(15:0)" name="data_out(15:0)" />
        </block>
        <block symbolname="ex_reg_ver" name="XLXI_1">
            <blockpin signalname="reset" name="reset" />
            <blockpin signalname="clock" name="clock" />
            <blockpin signalname="ce_reg1" name="ce_reg" />
            <blockpin signalname="data_in1(15:0)" name="data_in(15:0)" />
            <blockpin signalname="data_out1(15:0)" name="data_out(15:0)" />
        </block>
    </netlist>
    <sheet sheetnum="1" width="3520" height="2720">
        <branch name="mux_sel">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="2208" y="400" type="branch" />
            <wire x2="2288" y1="400" y2="400" x1="2208" />
        </branch>
        <branch name="data_out1(15:0)">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="2208" y="464" type="branch" />
            <wire x2="2288" y1="464" y2="464" x1="2208" />
        </branch>
        <branch name="data_out2(15:0)">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="2208" y="528" type="branch" />
            <wire x2="2288" y1="528" y2="528" x1="2208" />
        </branch>
        <branch name="data_mux_out(15:0)">
            <wire x2="2752" y1="400" y2="400" x1="2736" />
            <wire x2="3008" y1="400" y2="400" x1="2752" />
        </branch>
        <instance x="2144" y="1360" name="XLXI_5" orien="R0">
        </instance>
        <branch name="buf_en1">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="2032" y="976" type="branch" />
            <wire x2="2128" y1="976" y2="976" x1="2032" />
        </branch>
        <branch name="buf_en2">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="2064" y="1264" type="branch" />
            <wire x2="2144" y1="1264" y2="1264" x1="2064" />
        </branch>
        <branch name="data_buf_out(15:0)">
            <wire x2="2672" y1="976" y2="976" x1="2512" />
            <wire x2="2672" y1="976" y2="1264" x1="2672" />
            <wire x2="2944" y1="976" y2="976" x1="2672" />
            <wire x2="2672" y1="1264" y2="1264" x1="2528" />
        </branch>
        <instance x="2128" y="1072" name="XLXI_4" orien="R0">
        </instance>
        <branch name="data_out1(15:0)">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="2048" y="1040" type="branch" />
            <wire x2="2128" y1="1040" y2="1040" x1="2048" />
        </branch>
        <branch name="data_out2(15:0)">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="2064" y="1328" type="branch" />
            <wire x2="2144" y1="1328" y2="1328" x1="2064" />
        </branch>
        <instance x="2288" y="560" name="XLXI_3" orien="R0">
        </instance>
        <iomarker fontsize="28" x="3008" y="400" name="data_mux_out(15:0)" orien="R0" />
        <iomarker fontsize="28" x="2944" y="976" name="data_buf_out(15:0)" orien="R0" />
        <instance x="1184" y="992" name="XLXI_2" orien="R0">
        </instance>
        <branch name="reset">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="1104" y="304" type="branch" />
            <wire x2="1120" y1="304" y2="304" x1="1104" />
            <wire x2="1200" y1="304" y2="304" x1="1120" />
        </branch>
        <branch name="reset">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="1104" y="768" type="branch" />
            <wire x2="1184" y1="768" y2="768" x1="1104" />
        </branch>
        <branch name="clock">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="1104" y="368" type="branch" />
            <wire x2="1120" y1="368" y2="368" x1="1104" />
            <wire x2="1200" y1="368" y2="368" x1="1120" />
        </branch>
        <branch name="clock">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="1104" y="832" type="branch" />
            <wire x2="1184" y1="832" y2="832" x1="1104" />
        </branch>
        <branch name="ce_reg1">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="1120" y="432" type="branch" />
            <wire x2="1136" y1="432" y2="432" x1="1120" />
            <wire x2="1200" y1="432" y2="432" x1="1136" />
        </branch>
        <branch name="ce_reg2">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="1104" y="896" type="branch" />
            <wire x2="1184" y1="896" y2="896" x1="1104" />
        </branch>
        <branch name="data_in1(15:0)">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="1072" y="496" type="branch" />
            <wire x2="1088" y1="496" y2="496" x1="1072" />
            <wire x2="1200" y1="496" y2="496" x1="1088" />
        </branch>
        <branch name="data_in2(15:0)">
            <attrtext style="alignment:SOFT-RIGHT;fontsize:28;fontname:Arial" attrname="Name" x="1072" y="960" type="branch" />
            <wire x2="1184" y1="960" y2="960" x1="1072" />
        </branch>
        <branch name="data_out1(15:0)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="1712" y="304" type="branch" />
            <wire x2="1696" y1="304" y2="304" x1="1632" />
            <wire x2="1712" y1="304" y2="304" x1="1696" />
        </branch>
        <branch name="data_out2(15:0)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="1712" y="768" type="branch" />
            <wire x2="1712" y1="768" y2="768" x1="1616" />
        </branch>
        <instance x="1200" y="528" name="XLXI_1" orien="R0">
        </instance>
        <branch name="reset">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="528" y="128" type="branch" />
            <wire x2="528" y1="128" y2="128" x1="416" />
        </branch>
        <branch name="clock">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="544" y="208" type="branch" />
            <wire x2="544" y1="208" y2="208" x1="416" />
        </branch>
        <branch name="ce_reg1">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="512" y="320" type="branch" />
            <wire x2="512" y1="320" y2="320" x1="416" />
        </branch>
        <branch name="ce_reg2">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="528" y="544" type="branch" />
            <wire x2="528" y1="544" y2="544" x1="400" />
        </branch>
        <branch name="data_in1(15:0)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="560" y="400" type="branch" />
            <wire x2="560" y1="400" y2="400" x1="480" />
        </branch>
        <branch name="data_in2(15:0)">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="576" y="624" type="branch" />
            <wire x2="576" y1="624" y2="624" x1="480" />
        </branch>
        <branch name="mux_sel">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="640" y="752" type="branch" />
            <wire x2="640" y1="752" y2="752" x1="512" />
        </branch>
        <branch name="buf_en1">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="656" y="848" type="branch" />
            <wire x2="656" y1="848" y2="848" x1="528" />
        </branch>
        <branch name="buf_en2">
            <attrtext style="alignment:SOFT-LEFT;fontsize:28;fontname:Arial" attrname="Name" x="672" y="944" type="branch" />
            <wire x2="672" y1="944" y2="944" x1="528" />
        </branch>
        <iomarker fontsize="28" x="416" y="128" name="reset" orien="R180" />
        <iomarker fontsize="28" x="416" y="208" name="clock" orien="R180" />
        <iomarker fontsize="28" x="416" y="320" name="ce_reg1" orien="R180" />
        <iomarker fontsize="28" x="480" y="400" name="data_in1(15:0)" orien="R180" />
        <iomarker fontsize="28" x="480" y="624" name="data_in2(15:0)" orien="R180" />
        <iomarker fontsize="28" x="512" y="752" name="mux_sel" orien="R180" />
        <iomarker fontsize="28" x="528" y="848" name="buf_en1" orien="R180" />
        <iomarker fontsize="28" x="528" y="944" name="buf_en2" orien="R180" />
        <iomarker fontsize="28" x="400" y="544" name="ce_reg2" orien="R180" />
    </sheet>
</drawing>