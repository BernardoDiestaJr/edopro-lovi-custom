--Umbriazic Supreme Lord Tyranno
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon Procedure: 3 Level 6 Dinosaur monsters OR 1 Level 7 or higher "Umbriazic" monster you control
	Xyz.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_DINOSAUR),6,3,s.ovfilter,aux.Stringid(id,0),3,s.xyzop)
	--Your Dinosaur monsters can attack directly while your opponent controls a face-down monster.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(function(e,c) return c:IsRace(RACE_DINOSAUR) end)
	e1:SetCondition(function(e) return Duel.IsExistingMatchingCard(Card.IsFacedown,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil) end)
	c:RegisterEffect(e1)
	--Change as many non-Dinosaur monsters on the field as possible to face-down Defense Position, then, if either player controls a face-up non-Dinosaur monster(s), they must banish all face-up non-Dinosaur monsters they control.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) end)
	e2:SetCost(Cost.DetachFromSelf(1,1,nil))
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
	--Add 1 non-DARK Dinosaur monster from your GY or banishment
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return r&REASON_EFFECT>0 end)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)

end

s.listed_series={0x2f0}
s.listed_names={id}

function s.ovfilter(c,tp,lc)
	return c:IsFaceup() and c:IsSetCard(0x2f0,lc,SUMMON_TYPE_XYZ,tp) and c:IsLevelAbove(7)
end

function s.xyzop(e,tp,chk)
	if chk==0 then return not Duel.HasFlagEffect(tp,id) end
	return Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,EFFECT_FLAG_OATH,1)
end

function s.filter1(c)
	return not c:IsRace(RACE_DINOSAUR) and c:IsFaceup()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
	local tg=Duel.GetMatchingGroup(aux.NOT(Card.IsCanTurnSet),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #tg>0 then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,tg,#tg,0,0)
	end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g>0 and Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)>0 then
		local turn_p=Duel.GetTurnPlayer()
		local g1=Duel.GetMatchingGroup(s.filter1,turn_p,LOCATION_MZONE,0,nil)
		local g2=Duel.GetMatchingGroup(s.filter1,turn_p,0,LOCATION_MZONE,nil)
		if #g1==0 and #g2==0 then return end
		Duel.BreakEffect()
		if #g1>0 then
			Duel.Remove(g1,REASON_RULE,PLAYER_NONE,turn_p)
		end
		if #g2>0 then
			Duel.Remove(g2,REASON_RULE,PLAYER_NONE,1-turn_p)
		end
	end
end

function s.thfilter(c)
	return not c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_DINOSAUR) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end