--Onmyō Gemsmith Misumaru
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	local sme,soe=Spirit.AddProcedure(c,EVENT_SPSUMMON_SUCCESS)
	--Mandatory return
	sme:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	sme:SetTarget(s.mrettg)
	sme:SetOperation(s.retop)
	--Optional return
	soe:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	soe:SetTarget(s.orettg)
	soe:SetOperation(s.retop)
	--You can Tribute this card from your hand; add 1 "Onmyō" card from your Deck, GY or banishment to your hand.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCost(Cost.SelfTribute)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)	
	--Send 1 DARK Illusion monster from your Deck to the GY, then you can Special Summon 1 Level 4 Spellcaster "Fantasia" monster from your Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tgsptg)
	e2:SetOperation(s.tgspop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)	
end

s.listed_names={id,81519991,81519992}
s.listed_series={0x1f8,0x1fa}

function s.sptktp(sum_player,target_player)
	return Duel.IsPlayerCanSpecialSummonMonster(sum_player,81519991,0,TYPES_TOKEN,900,600,6,RACE_ROCK,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE,target_player)
end

function s.mrettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and s.sptktp(tp,tp)
		and s.sptktp(tp,1-tp) end
	Spirit.MandatoryReturnTarget(e,tp,eg,ep,ev,re,r,rp,1)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,0,2,PLAYER_ALL,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,0,2,PLAYER_ALL,0)
end

function s.orettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and s.sptktp(tp,tp)
		and s.sptktp(tp,1-tp)
		and Spirit.OptionalReturnTarget(e,tp,eg,ep,ev,re,r,rp,0) end
	Spirit.OptionalReturnTarget(e,tp,eg,ep,ev,re,r,rp,1)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,0,2,PLAYER_ALL,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,0,2,PLAYER_ALL,0)
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)>0
		and c:IsLocation(LOCATION_HAND) and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and s.sptktp(tp,tp) and s.sptktp(tp,1-tp) then
		Duel.BreakEffect()
		local token1=Duel.CreateToken(tp,81519991)
		Duel.SpecialSummonStep(token1,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		local token2=Duel.CreateToken(tp,81519991)
		Duel.SpecialSummonStep(token2,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
		end
		Duel.SpecialSummonComplete()
	end


function s.thfilter(c)
	return c:IsSetCard(0x1fa) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.tgfilter(c)
	return c:IsRace(RACE_ILLUSION) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToGrave()
end

function s.spfilter(c,e,tp)
	return c:IsLevel(4) and c:IsRace(RACE_SPELLCASTER) and c:IsSetCard(0x1f8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.tgsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end

function s.tgspop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 then
		local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		if #sg==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local ssg=sg:Select(tp,1,1,nil)
		if #ssg>0 then
			Duel.BreakEffect()
			Duel.SpecialSummon(ssg,0,tp,tp,true,false,POS_FACEUP)
		end		
	end
end