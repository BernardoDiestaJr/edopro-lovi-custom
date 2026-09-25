--Malevolent Matrimony
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x118a)
	--Add 1 Fairy "Malevolent" monster from your Deck to your hand, then you can count the number of "Crawling Chaos" and "Malevolent" cards you control and/or have in your GY or banishment, and place that many Black Soul Counters among card(s) you control that you can place a Black Soul Counter on
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.thtg1)
	e1:SetOperation(s.thop1)
	c:RegisterEffect(e1)
	--Target 1 "Grimm the Tragic Knight" or 1 monster that mentions it in your GY; add it to your hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.thtg2)
	e2:SetOperation(s.thop2)
	c:RegisterEffect(e2)	
	
end

s.counter_place_list={0x118a}
s.listed_series={0x41f,0x422}
s.listed_names={id,13741143}

function s.thfilter1(c)
	return c:IsSetCard(0x422) and c:IsRace(RACE_FAIRY) and c:IsAbleToHand()
end

function s.counterfilter(c)
	return (c:IsSetCard(0x41f) or c:IsSetCard(0x422))
end


function s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop1(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		Duel.ConfirmCards(1-tp,g)
		local ct=Duel.GetMatchingGroupCount(s.counterfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE|LOCATION_REMOVED,0,nil)
		local cg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCanAddCounter,0x118a,1),tp,LOCATION_ONFIELD,0,nil)
		if ct>0 and #cg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.BreakEffect()
			while ct>0 and #cg>0 do
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)
				cg:Select(tp,1,1,nil):GetFirst():AddCounter(0x118a,1)
				ct=ct-1
				cg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCanAddCounter,0x118a,1),tp,LOCATION_ONFIELD,0,nil)
			end
		end
	end
end

function s.thfilter2(c)
	return (c:IsCode(13741143) or c:ListsCode(13741143)) and c:IsFaceup() and c:IsAbleToHand()
end

function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.thfilter2(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter2,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter2,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
end

function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,tp,REASON_EFFECT)
	end
end