--Black Trial Knight Lindamea
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon Procedure: 2 Level 12 DARK monsters
	Xyz.AddProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),12,2,s.xyzfilter,aux.Stringid(id,0),2,s.xyzop)
	--Gains these effects while in the Extra Monster Zone
	--If this card in the Extra Monster Zone attacks a Defense Position monster, inflict piercing battle damage to your opponent
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_EMZONE)
	c:RegisterEffect(e1)
	--While this Xyz Summoned card is in the Extra Monster Zone, it is unaffected by your opponent's activated effects, unless they target this card
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_EMZONE)
	e2:SetCondition(s.indescon)
	e2:SetValue(s.immval)
	c:RegisterEffect(e2)
	--Any battle damage your opponent takes from battles involving this card is doubled
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_EMZONE)
	e3:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e3)
	--If this card is in the Extra Monster Zone (Quick Effect): You can detach 1 material from this card, then target up to 3 card your opponent controls; banish them face-down
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_EMZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCost(Cost.DetachFromSelf(1))
	e4:SetTarget(s.rmvtg)
	e4:SetOperation(s.rmvop)
	e4:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e4)	
	--Count summons
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SUMMON_SUCCESS)
		Duel.RegisterEffect(ge2,0)
	end)
end

s.listed_series={0x421}
s.listed_names={id,13741143}

function s.xyzfilter(c,tp,xyzc)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	return #g>0
end

function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	for tc in aux.Next(eg) do
		Duel.RegisterFlagEffect(tc:GetSummonPlayer(),id,RESET_PHASE|PHASE_END,0,1)
		if Duel.HasFlagEffect(tc:GetSummonPlayer(),id,5)then
			Duel.RegisterFlagEffect(tc:GetSummonPlayer(),id+1,RESET_PHASE|PHASE_END,0,5)
		end
	end
end

function s.xyzop(e,tp,chk)
	if chk==0 then return Duel.HasFlagEffect(1-tp,id+1) end
	--Cannot Special Summon for the rest of this turn, except non-Zombie "Black Trial" monsters and "Grimm the Tragic Knight"
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return not ((not c:IsRace(RACE_ZOMBIE) and c:IsSetCard(0x421)) or c:IsCode(13741143)) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	return true
end

function s.indescon(e)
	return e:GetHandler():IsXyzSummoned()
end

function s.immval(e,re)
	local c=e:GetHandler()
	if not (re:IsActivated() and c:IsXyzSummoned() and e:GetOwnerPlayer()==1-re:GetOwnerPlayer()) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return true end
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	return not g or not g:IsContains(c)
end

function s.rmvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,0)
end

function s.rmvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	end
end

