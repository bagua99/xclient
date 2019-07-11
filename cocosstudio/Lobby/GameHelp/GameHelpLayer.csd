<GameFile>
  <PropertyGroup Name="GameHelpLayer" Type="Layer" ID="b9394742-6075-405a-8d97-2568649f78ed" Version="3.10.0.0" />
  <Content ctype="GameProjectContent">
    <Content>
      <Animation Duration="0" Speed="1.0000" />
      <ObjectData Name="Layer" Tag="56" ctype="GameLayerObjectData">
        <Size X="1136.0000" Y="640.0000" />
        <Children>
          <AbstractNodeData Name="BG" ActionTag="1871927375" Tag="763" IconVisible="False" TouchEnable="True" ClipAble="False" BackColorAlpha="102" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" ctype="PanelObjectData">
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
          <AbstractNodeData Name="Bg" ActionTag="-2038134859" Tag="422" IconVisible="False" LeftMargin="48.5100" RightMargin="-6.5100" TopMargin="47.0000" BottomMargin="7.0000" LeftEage="343" RightEage="343" TopEage="186" BottomEage="186" Scale9OriginX="343" Scale9OriginY="186" Scale9Width="408" Scale9Height="214" ctype="ImageViewObjectData">
            <Size X="1094.0000" Y="586.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="595.5100" Y="300.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.5242" Y="0.4688" />
            <PreSize X="0.9630" Y="0.9156" />
            <FileData Type="PlistSubImage" Path="GameHelp_BG.png" Plist="Lobby/GameHelp/GameHelp.plist" />
          </AbstractNodeData>
          <AbstractNodeData Name="ScrollView" ActionTag="1312491533" Tag="597" IconVisible="False" LeftMargin="330.0000" RightMargin="106.0000" TopMargin="170.0000" BottomMargin="110.0000" TouchEnable="True" ClipAble="True" BackColorAlpha="0" ColorAngle="90.0000" Scale9Width="1" Scale9Height="1" IsBounceEnabled="True" ScrollDirectionType="Vertical" ctype="ScrollViewObjectData">
            <Size X="700.0000" Y="360.0000" />
            <Children>
              <AbstractNodeData Name="DescText" ActionTag="-1214124951" Tag="70" IconVisible="False" RightMargin="100.0000" IsCustomSize="True" FontSize="20" LabelText="基本规则&#xA;一、游戏人数：3人（2人）&#xA;二、游戏牌数：一副牌去掉大小王、去掉一个A、去掉3个2，共剩48张牌，每人16张；一手牌中只有1个2，3个A。&#xA;三、出牌顺序&#xA;每局首出都由玩家创建房间时选中方式进行出牌，可以出任意的牌型，然后其他玩家依次出牌。&#xA;四、牌型&#xA;1、单张：任意1账单牌&#xA;2、顺子：任意5张或者5张以上点数相连的牌。特殊：2是最大的单牌，不能当顺子出！&#xA;3、对子：可以打单对，如：44&#xA;4、连对：2对或2对以上点数相连的牌，如：5566&#xA;5、三带二：点数相同的3张牌＋一对牌或者点数相同的3张牌＋2张不同的单牌，如：55577或者55567&#xA;6、三带一：打到最后剩4张牌的时候，才可以3带1&#xA;7、没打完的情况下，不可以出3张点数相同的牌！最后只剩3张牌的时候可以不带&#xA;8、飞机：两顺或以上＋数量相同的对牌，如：555666+99；也可以带4张单牌，如：555666+78910&#xA;9、在有牌的情况下，出555666必须带4张牌，除非牌不够不带活着带少牌&#xA;10、炸弹：4张点数相同的牌，如6666，7777&#xA;11、关门：有一家牌已经出完，另一家或者两家1张牌都没出，此时的状态称为关门&#xA;12、报单放走包陪&#xA;13、牌型的比较点数大小，从大到小依次为：2、A、K、Q、J、10、9、8、7、6、5、4、3&#xA;五、积分规则：&#xA;一张牌1分&#xA;1个炸10分&#xA;报单不出不进&#xA;关门：被关门者剩余牌的张数*2（和炸弹可累加）&#xA;创建房间功能说明：&#xA;1、10局（房卡x1）：游戏进行总局数为10，10局结束后消耗1张房卡。&#xA;2、20局（房卡x2）：游戏进行总局数为20，20局结束后消耗2张房卡。&#xA;3、3人玩：这次玩家参与人数为3人。&#xA;4、4人玩：这次玩家参与人数为2人。&#xA;5、显示牌：游戏开始后，显示全部玩家还有多少手牌。&#xA;6、不显示牌：游戏开始后，不显示玩家还有多少手牌。&#xA;7、庄家先出：游戏由庄家开始出第一轮手牌，牌型可自由搭配。&#xA;8、黑桃3先出：游戏由手牌存在黑桃3的玩家开始第一轮手牌。牌型可自由搭配。&#xA;9、黑桃3必出：游戏开始后，第一轮手牌必出包含黑牌3的组合。&#xA;10、必须管：上家打出的牌下家能压下必须压下。&#xA;11、可不要：上家打出的牌型下家能压下的可以选择［不出］该牌。&#xA;七、注意项&#xA;黑桃3先出和黑桃3必出为绑定关系，只有在选择黑桃3先出的情况下才可以选择黑桃3必出。&#xA;八、红桃10扎鸟&#xA;在湖南地区比较流行的一种打法，也就是红桃10叫做鸟，拿到鸟牌（红桃10）的玩家，这时候不管输赢都是所输赢积分的2给，炸弹则不翻倍。&#xA;" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="TextObjectData">
                <Size X="700.0000" Y="1600.0000" />
                <AnchorPoint ScaleY="1.0000" />
                <Position Y="1600.0000" />
                <Scale ScaleX="1.0000" ScaleY="1.0000" />
                <CColor A="255" R="255" G="255" B="255" />
                <PrePosition Y="1.0000" />
                <PreSize X="0.8750" Y="1.0000" />
                <FontResource Type="Normal" Path="commonfont/ZYUANSJ.TTF" Plist="" />
                <OutlineColor A="255" R="255" G="0" B="0" />
                <ShadowColor A="255" R="110" G="110" B="110" />
              </AbstractNodeData>
            </Children>
            <AnchorPoint />
            <Position X="330.0000" Y="110.0000" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.2905" Y="0.1719" />
            <PreSize X="0.6162" Y="0.5625" />
            <SingleColor A="255" R="255" G="150" B="100" />
            <FirstColor A="255" R="255" G="150" B="100" />
            <EndColor A="255" R="255" G="255" B="255" />
            <ColorVector ScaleY="1.0000" />
            <InnerNodeSize Width="800" Height="1600" />
          </AbstractNodeData>
          <AbstractNodeData Name="ButtonScrollView" ActionTag="1132071403" Tag="28" IconVisible="False" LeftMargin="101.0021" RightMargin="814.9979" TopMargin="170.9996" BottomMargin="109.0004" TouchEnable="True" ClipAble="True" BackColorAlpha="102" ColorAngle="90.0000" Scale9Enable="True" LeftEage="24" RightEage="24" TopEage="24" BottomEage="24" Scale9OriginX="-24" Scale9OriginY="-24" Scale9Width="48" Scale9Height="48" IsBounceEnabled="True" ScrollDirectionType="Vertical" ctype="ScrollViewObjectData">
            <Size X="220.0000" Y="360.0000" />
            <AnchorPoint />
            <Position X="101.0021" Y="109.0004" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.0889" Y="0.1703" />
            <PreSize X="0.1937" Y="0.5625" />
            <SingleColor A="255" R="255" G="255" B="255" />
            <FirstColor A="255" R="255" G="150" B="100" />
            <EndColor A="255" R="255" G="255" B="255" />
            <ColorVector ScaleY="1.0000" />
            <InnerNodeSize Width="220" Height="420" />
          </AbstractNodeData>
          <AbstractNodeData Name="CloseBtn" ActionTag="789703415" Tag="423" IconVisible="False" LeftMargin="1052.1794" RightMargin="5.8206" TopMargin="13.5774" BottomMargin="547.4226" TouchEnable="True" FontSize="14" Scale9Enable="True" LeftEage="15" RightEage="15" TopEage="11" BottomEage="11" Scale9OriginX="15" Scale9OriginY="11" Scale9Width="48" Scale9Height="57" ShadowOffsetX="2.0000" ShadowOffsetY="-2.0000" ctype="ButtonObjectData">
            <Size X="78.0000" Y="79.0000" />
            <AnchorPoint ScaleX="0.5000" ScaleY="0.5000" />
            <Position X="1091.1794" Y="586.9226" />
            <Scale ScaleX="1.0000" ScaleY="1.0000" />
            <CColor A="255" R="255" G="255" B="255" />
            <PrePosition X="0.9605" Y="0.9171" />
            <PreSize X="0.0687" Y="0.1234" />
            <TextColor A="255" R="65" G="65" B="70" />
            <DisabledFileData Type="Default" Path="Default/Button_Disable.png" Plist="" />
            <PressedFileData Type="PlistSubImage" Path="GameHelp_Close_.png" Plist="Lobby/GameHelp/GameHelp.plist" />
            <NormalFileData Type="PlistSubImage" Path="GameHelp_Close_.png" Plist="Lobby/GameHelp/GameHelp.plist" />
            <OutlineColor A="255" R="255" G="0" B="0" />
            <ShadowColor A="255" R="110" G="110" B="110" />
          </AbstractNodeData>
        </Children>
      </ObjectData>
    </Content>
  </Content>
</GameFile>