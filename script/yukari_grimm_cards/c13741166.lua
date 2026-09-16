--Black Trial Worshipper
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Reveal this card and 1 "Black Trial Judge Baphomet" in your Extra Deck; banish up to 3 "Black Trial" cards from your Deck face-down, except "Black Trial Worshipper", then you can add 1 face-down banished "Black Trial" card
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND)
	e0:SetType(EFFECT_TYPE_IGNITION)
	e0:SetRange(LOCATION_HAND)
	e0:SetCountLimit(1,{id,0})
	e0:SetCost(s.rmvcost)
	e0:SetTarget(s.rmvtg)
	e0:SetOperation(s.rmvop)
	c:RegisterEffect(e0)
	--Set 1 (face-up or face-down) "Black Trial" Spell/Trap from your Deck or banishment, and if you Set a Normal Trap or Quick-Play Spell, it can be activated this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCategory(CATEGORY_SET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) end)
	e1:SetCost(Cost.SelfDiscard)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)

end

s.listed_series={0x421}
s.listed_names={id,13741170}

function s.rmvcostfilter(c,e,tp)
	return c:IsCode(13741170) and not c:IsPublic()
end

function s.rmvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsPublic() and Duel.IsExistingMatchingCard(s.rmvcostfilter,tp,LOCATION_EXTRA,0,1,c,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local rc=Duel.SelectMatchingCard(tp,s.rmvcostfilter,tp,LOCATION_EXTRA,0,1,1,c,e,tp):GetFirst()
	Duel.ConfirmCards(1-tp,Group.FromCards(c,rc))
	Duel.ShuffleHand(tp)
end

function s.rmvfilter(c)
	return c:IsSetCard(0x421) and not c:IsCode(id) and c:IsAbleToRemove()
end

function s.thfilter(c)
	return c:IsFacedown() and c:IsSetCard(0x421) and c:IsAbleToHand()
end

function s.rmvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmvfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_REMOVED)
end

function s.rmvop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmvfilter,tp,LOCATION_DECK,0,1,3,nil)
	if #g>0 and Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT) then
		local hg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_REMOVED,0,nil)
		if #hg==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local hsg=hg:Select(tp,1,1,nil)
		if #hsg>0 then
			Duel.BreakEffect()
			Duel.SendtoHand(hsg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,hsg)
		end
	end
end

function s.setfilter(c)
	return (c:IsFacedown() or c:IsFaceup()) and c:IsSetCard(0x421) and c:IsSpellTrap() and c:IsSSetable()
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_REMOVED|LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SET,nil,1,tp,LOCATION_REMOVED|LOCATION_DECK)
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local sc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_REMOVED|LOCATION_DECK,0,1,1,nil):GetFirst()
	if sc and Duel.SSet(tp,sc)>0 then
		local effcode=nil
		if sc:IsQuickPlaySpell() then
			effcode=EFFECT_QP_ACT_IN_SET_TURN
		elseif sc:IsTrap() then
			effcode=EFFECT_TRAP_ACT_IN_SET_TURN
		end
		if effcode then
			--If you Set a Trap or Quick-Play Spell, it can be activated this turn
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(effcode)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			sc:RegisterEffect(e1)
		end
	end
end