--Black Trial Fated Duel
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Monsters that mention "Grimm the Tragic Knight" cannot be destroyed by battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(function(e,c) return c:ListsCode(13741143) end)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--You take no battle damage from battles involving monsters that mention "Grimm the Tragic Knight"
	local e2=e1:Clone()
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetValue(aux.ChangeBattleDamage(0,0))
	c:RegisterEffect(e2)
	--Activate 1 of these effects	
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.condition)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)	
end

s.listed_series={0x421}
s.listed_names={id,13741143}
local locs=LOCATION_HAND|LOCATION_DECK

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
end

function s.thfilter(c)
	return (c:IsMonster() and c:IsSetCard(0x421) or c:IsCode(13741143)) and c:IsFaceup() and c:IsAbleToHand()
end

function s.firstsummon(c,e,tp,sg)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
	and sg:IsExists(s.secondsummon,1,c,e,tp) --exclude 'c'
end

function s.secondsummon(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp) and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
end

function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsCode,nil,13741143)==1
		and sg:FilterCount(Card.IsSetCard,nil,0x421)==1
		and sg:IsExists(s.firstsummon,1,nil,e,tp,sg)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	--Special Summon 1 "Grimm the Tragic Knight" monster and 1 "Black Trial" monster from your hand, Deck, and/or Extra Deck
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	--Add 1 of your banished "Black Trial" monsters or "Grimm the Tragic Knight" to your hand
	local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_REMOVED,0,1,nil)
	if chk==0 then return b1 or b2 
		and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,locs)
	elseif op==2 then
		e:SetCategory(CATEGORY_TOHAND)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
	end
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Special Summon 1 "Grimm the Tragic Knight" Pendulum Monster and 1 "Black Trial" Pendulum Monster from your hand, Deck, and/or Extra Deck
		if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
		local c=e:GetHandler()
		--Special Summon 1 "Grimm the Tragic Knight" monster and 1 "Black Trial" monster
		local g1=Duel.GetMatchingGroup(Card.IsCode,tp,locs,0,nil,13741143)
		local g2=Duel.GetMatchingGroup(Card.IsSetCard,tp,locs,0,nil,0x421)
		if #g1==0 or #g2==0 then return end
		local g=g1+g2
		local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_SPSUMMON)
		if #sg~=2 then return end
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
		local sc1=sg:FilterSelect(tp,s.firstsummon,1,1,nil,e,tp,sg):GetFirst()
		local sc2=sg:RemoveCard(sc1):GetFirst()
		Duel.SpecialSummonStep(sc1,0,tp,tp,false,false,POS_FACEUP)
		Duel.SpecialSummonStep(sc2,0,tp,1-tp,false,false,POS_FACEUP)
		Duel.SpecialSummonComplete()
		--Cannot Special Summon monsters, except Level/Rank 7 monsters
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,4))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,1)
		e1:SetTarget(function(_,c) return not (c:IsLevel(7) or c:IsRank(7)) end)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	elseif op==2 then
		--Add 1 of your banished "Black Trial" monsters or "Grimm the Tragic Knight" to your hand
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end