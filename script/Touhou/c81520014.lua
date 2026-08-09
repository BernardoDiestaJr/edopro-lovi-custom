--Windrous Suwa War
local s,id=GetID()
function s.initial_effect(c)
	--Choose 1 face-up WIND Synchro Monster you control, and destroy all monsters in the Main Monster Zones, except the chosen monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	
end

s.listed_series={0x2f1}
s.listed_names={id,81520004,81520005}

--If a "Windrous" Monster Card is on the field and your opponent controls 3 or more monsters than you do
function s.windrousfilter(c)
	return c:IsSetCard(0x2f1) and c:IsMonsterCard() and c:IsFaceup()
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.windrousfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)-Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>=3
end

function s.extrafilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsFaceup()
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.extrafilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MMZONE,LOCATION_MMZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local sc=Duel.SelectMatchingCard(tp,s.extrafilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
	if not sc then return end
	Duel.HintSelection(sc)
	local c=e:GetHandler()
	local exc=c:IsRelateToEffect(e) and Group.FromCards(sc,c) or sc
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MMZONE,LOCATION_MMZONE,exc)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
	sc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
	--Its effects are negated
	sc:NegateEffects(c,RESET_EVENT|RESETS_STANDARD)
	--It cannot attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	sc:RegisterEffect(e1)
	--It cannot be Tributed
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UNRELEASABLE_SUM)
	e2:SetValue(1)
	sc:RegisterEffect(e2)	
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	sc:RegisterEffect(e3)
	--It cannot be used as material for a Fusion, Synchro, Xyz, or Link Summon
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e4:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
	sc:RegisterEffect(e4)	
	
end
