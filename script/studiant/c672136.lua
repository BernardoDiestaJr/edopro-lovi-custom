--Studiant Shichido Yukino
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--During the Main Phase: You can activate 1 of these effects;
	--● If you control no monsters: You can place 1 "Studiant" card from your hand or GY on the top or bottom of the Deck, then send the top card of your Deck to the GY.
	--● If you control a Rank 3 or 5 "Studiant" Xyz Monster: You can target 1 "Studiant" card in your GY or banishment, except "Studiant Shichido Yukino"; add it to your hand, then discard 1 card.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,{id,0})
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	--If this card is sent to the GY, except from the field: You can place this card face-up on your field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e) return not e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) end)
	e2:SetTarget(s.pltg)
	e2:SetOperation(s.plop)
	c:RegisterEffect(e2)
end

s.listed_series={0x45e}
s.listed_names={id}

function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end

function s.drconfilter(c)
	return c:IsSetCard(0x45e) and (c:IsType(TYPE_XYZ) and c:IsRank(3) or c:IsType(TYPE_XYZ) and c:IsRank(5)) and c:IsFaceup()
end

function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	--● Place 1 card from your hand on the top or bottom of the Deck, then draw 1 card
	local option_1=Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,nil)
		and Duel.IsPlayerCanDraw(tp)
	--● If you control a Spellcaster "Raise Moon" Xyz Monster: You can draw 1 card
	local option_2=Duel.IsExistingMatchingCard(s.drconfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsPlayerCanDraw(tp,1)
	if chk==0 then return option_1 or option_2 end
	local choice=Duel.SelectEffect(tp,
		{option_1,aux.Stringid(id,2)},
		{option_2,aux.Stringid(id,3)})
	e:GetChainData().choice=choice
	if choice==1 then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,1,LOCATION_HAND)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	elseif choice==2 then
		e:SetCategory(CATEGORY_DRAW)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end

function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local choice=e:GetChainData().choice
	if choice==1 then
		--● Place 1 card from your hand on the top or bottom of the Deck, then draw 1 card
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sc=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
		if not sc then return end
		local seq_op=0
		if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 then
			seq_op=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5))
		end
		if Duel.SendtoDeck(sc,nil,seq_op,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_DECK)
			and Duel.IsPlayerCanDraw(tp) then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	elseif choice==2 then
		--● If you control a Spellcaster "Raise Moon" Xyz Monster: You can draw 1 card
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end

function s.plop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
