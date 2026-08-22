<?xml version="1.0" encoding="UTF-8"?>
<drawing version="7">
    <attr value="spartan6" name="DeviceFamilyName">
        <trait delete="all:0" />
        <trait editname="all:0" />
        <trait edittrait="all:0" />
    </attr>
    <netlist>
        <signal name="ci" />
        <signal name="A(15:0)" />
        <signal name="B(15:0)" />
        <signal name="ADD" />
        <signal name="S(15:0)" />
        <signal name="OFL" />
        <signal name="CO" />
        <port polarity="Input" name="ci" />
        <port polarity="Input" name="A(15:0)" />
        <port polarity="Input" name="B(15:0)" />
        <port polarity="Input" name="ADD" />
        <port polarity="Output" name="S(15:0)" />
        <port polarity="Output" name="OFL" />
        <port polarity="Output" name="CO" />
        <blockdef name="adsu16">
            <timestamp>2000-1-1T10:10:10</timestamp>
            <line x2="384" y1="-64" y2="-64" x1="240" />
            <line x2="240" y1="-124" y2="-64" x1="240" />
            <rect width="64" x="0" y="-204" height="24" />
            <rect width="64" x="0" y="-332" height="24" />
            <rect width="64" x="384" y="-268" height="24" />
            <line x2="64" y1="-448" y2="-448" x1="128" />
            <line x2="128" y1="-416" y2="-448" x1="128" />
            <line x2="48" y1="-64" y2="-64" x1="128" />
            <line x2="128" y1="-96" y2="-64" x1="128" />
            <line x2="64" y1="-288" y2="-432" x1="64" />
            <line x2="64" y1="-256" y2="-288" x1="128" />
            <line x2="128" y1="-224" y2="-256" x1="64" />
            <line x2="64" y1="-80" y2="-224" x1="64" />
            <line x2="64" y1="-160" y2="-80" x1="384" />
            <line x2="384" y1="-336" y2="-160" x1="384" />
            <line x2="384" y1="-352" y2="-336" x1="384" />
            <line x2="384" y1="-432" y2="-352" x1="64" />
            <line x2="336" y1="-128" y2="-148" x1="336" />
            <line x2="336" y1="-128" y2="-128" x1="384" />
            <line x2="384" y1="-256" y2="-256" x1="448" />
            <line x2="384" y1="-128" y2="-128" x1="448" />
            <line x2="384" y1="-64" y2="-64" x1="448" />
            <line x2="64" y1="-448" y2="-448" x1="0" />
            <line x2="64" y1="-192" y2="-192" x1="0" />
            <line x2="64" y1="-320" y2="-320" x1="0" />
            <line x2="64" y1="-64" y2="-64" x1="0" />
        </blockdef>
        <block symbolname="adsu16" name="XLXI_1">
            <blockpin signalname="A(15:0)" name="A(15:0)" />
            <blockpin signalname="ADD" name="ADD" />
            <blockpin signalname="B(15:0)" name="B(15:0)" />
            <blockpin signalname="ci" name="CI" />
            <blockpin signalname="CO" name="CO" />
            <blockpin signalname="OFL" name="OFL" />
            <blockpin signalname="S(15:0)" name="S(15:0)" />
        </block>
    </netlist>
    <sheet sheetnum="1" width="3520" height="2720">
        <instance x="1344" y="1456" name="XLXI_1" orien="R0" />
        <branch name="ci">
            <wire x2="1344" y1="1008" y2="1008" x1="1248" />
        </branch>
        <branch name="A(15:0)">
            <wire x2="1344" y1="1136" y2="1136" x1="1264" />
        </branch>
        <branch name="B(15:0)">
            <wire x2="1344" y1="1264" y2="1264" x1="1264" />
        </branch>
        <branch name="ADD">
            <wire x2="1344" y1="1392" y2="1392" x1="1232" />
        </branch>
        <branch name="S(15:0)">
            <wire x2="1872" y1="1200" y2="1200" x1="1792" />
        </branch>
        <branch name="OFL">
            <wire x2="1872" y1="1328" y2="1328" x1="1792" />
        </branch>
        <branch name="CO">
            <wire x2="1872" y1="1392" y2="1392" x1="1792" />
        </branch>
        <iomarker fontsize="28" x="1248" y="1008" name="ci" orien="R180" />
        <iomarker fontsize="28" x="1264" y="1136" name="A(15:0)" orien="R180" />
        <iomarker fontsize="28" x="1264" y="1264" name="B(15:0)" orien="R180" />
        <iomarker fontsize="28" x="1232" y="1392" name="ADD" orien="R180" />
        <iomarker fontsize="28" x="1872" y="1200" name="S(15:0)" orien="R0" />
        <iomarker fontsize="28" x="1872" y="1328" name="OFL" orien="R0" />
        <iomarker fontsize="28" x="1872" y="1392" name="CO" orien="R0" />
    </sheet>
</drawing>