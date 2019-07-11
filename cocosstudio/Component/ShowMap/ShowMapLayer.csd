<GameFile>
  <PropertyGroup Name="ShowMapLayer" Type="Layer" ID="5e01be52-003f-4ba0-8a03-4517001f29dc" Version="3.10.0.0" />
  <Content ctype="GameProjectContent">
    <Content>
      <Animation Duration="0" Speed="1.0000" />
      <ObjectData Name="Layer" Tag="228" ctype="GameLayerObjectData">
        <Size X="1136.0000" Y="640.0000" />
        <Children>
          <AbstractNodeData Name="BG" ActionTag="27132427" Tag="117" IconVisible="False" TouchEnable="True" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ctype="PanelObjectData">
            <Size X="1136.0000" Y="640.0000" />
            <AnchorPoint />
            <Position />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition />
            <PreSize X="1.0000" Y="1.0000" />
            <SingleColor A="255" R="150" G="200" B="255" />
            <FirstColor A="255" R="150" G="200" B="255" />
            <EndColor A="255" R="255" G="255" B="255" />
            <ColorVector ScaleY="1.0000" />
          </AbstractNodeData>
          <AbstractNodeData Name="IMG_BG" ActionTag="317679772" Tag="116" IconVisible="False" LeftEage="374" RightEage="374" TopEage="211" BottomEage="211" Scale9OriginX="374" Scale9OriginY="211" Scale9Width="388" Scale9Height="218" ctype="ImageViewObjectData">
            <Size X="1136.0000" Y="640.0000" />
            <AnchorPoint />
            <Position />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition />
            <PreSize X="1.0000" Y="1.0000" />
            <FileData Type="PlistSubImage" Path="ShowMap_locationTips.png" Plist="Component/ShowMap/ShowMap.plist" />
          </AbstractNodeData>
          <AbstractNodeData Name="Text_1" ActionTag="1605878504" Tag="118" IconVisible="False" LeftMargin="364.0005" RightMargin="363.9995" TopMargin="116.9941" BottomMargin="501.0059" FontSize="20" LabelText="以下玩家GPS位置较为接近，请选择是否继续:" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
            <Size X="408.0000" Y="22.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="568.0005" Y="512.0059" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="254" B="162" />
            <PrePosition X="0.5000" Y="0.8000" />
            <PreSize X="0.3592" Y="0.0344" />
            <FontResource Type="Normal" Path="commonfont/ZYUANSJ.TTF" Plist="" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="BTN_CONTINUE" ActionTag="676751142" Tag="123" IconVisible="False" LeftMargin="607.5451" RightMargin="286.4549" TopMargin="452.1700" BottomMargin="113.8300" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="212" Scale9Height="52" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
            <Size X="242.0000" Y="74.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="728.5451" Y="150.8300" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.6413" Y="0.2357" />
            <PreSize X="0.2130" Y="0.1156" />
            <TextColor A="255" R="65" G="65" B="70" />
            <DisabledFileData Type="Default" Path="Default/Button_Disable.png" Plist="" />
            <PressedFileData Type="PlistSubImage" Path="ShowMap_continue.png" Plist="Component/ShowMap/ShowMap.plist" />
            <NormalFileData Type="PlistSubImage" Path="ShowMap_continue.png" Plist="Component/ShowMap/ShowMap.plist" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="BTN_ENDGAME" ActionTag="452559358" Tag="124" IconVisible="False" LeftMargin="325.7749" RightMargin="580.2251" TopMargin="453.3135" BottomMargin="113.6865" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="200" Scale9Height="51" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
            <Size X="230.0000" Y="73.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="440.7749" Y="150.1865" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.3880" Y="0.2347" />
            <PreSize X="0.2025" Y="0.1141" />
            <TextColor A="255" R="65" G="65" B="70" />
            <DisabledFileData Type="Default" Path="Default/Button_Disable.png" Plist="" />
            <PressedFileData Type="PlistSubImage" Path="ShowMap_endgame.png" Plist="Component/ShowMap/ShowMap.plist" />
            <NormalFileData Type="PlistSubImage" Path="ShowMap_endgame.png" Plist="Component/ShowMap/ShowMap.plist" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="Text_2" ActionTag="-255542838" Tag="125" IconVisible="False" LeftMargin="369.4999" RightMargin="369.5001" TopMargin="425.0011" BottomMargin="192.9989" FontSize="20" LabelText="注意:位置信息并不一定准确，仅供玩家参考。" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
            <Size X="397.0000" Y="22.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="567.9999" Y="203.9989" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.5000" Y="0.3187" />
            <PreSize X="0.3495" Y="0.0344" />
            <FontResource Type="Normal" Path="commonfont/ZYUANSJ.TTF" Plist="" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
          <AbstractNodeData Name="ListView" ActionTag="1205382138" Tag="126" IconVisible="False" LeftMargin="226.0000" RightMargin="226.0000" TopMargin="162.0013" BottomMargin="237.9987" TouchEnable="True" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ScrollDirectionType="0" ItemMargin="5" DirectionType="Vertical" ctype="ListViewObjectData">
            <Size X="684.0000" Y="240.0000" />
            <AnchorPoint ScaleX="0.5000" />
            <Position X="568.0000" Y="237.9987" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.5000" Y="0.3719" />
            <PreSize X="0.6021" Y="0.3750" />
            <SingleColor A="255" R="150" G="150" B="255" />
            <FirstColor A="255" R="150" G="150" B="255" />
            <EndColor A="255" R="255" G="255" B="255" />
            <ColorVector ScaleY="1.0000" />
          </AbstractNodeData>
        </Children>
      </ObjectData>
    </Content>
  </Content>
</GameFile>