--Crawling Chaos Alice Amalgam
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x118a)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 Tuner + "Grimm the Tragic Knight"
	Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsCode,13741189),1,1,aux.FilterBoolFunction(Card.IsCode,13741143),1,1)
	--attack/defense up
	local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_SINGLE)
	e0a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0a:SetRange(LOCATION_MZONE)
	e0a:SetCode(EFFECT_UPDATE_ATTACK)
	e0a:SetValue(function(e,c) return Duel.GetCounter(0,1,1,0x118a)*1000 end)
	c:RegisterEffect(e0a)	
	local e0b=e0a:Clone()
	e0b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e0b)		
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.synlimit)
	c:RegisterEffect(e1)	
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e2)
	--Activate 1 of these effects
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCondition(s.effcon)
	e3:SetTarget(s.efftg)
	e3:SetOperation(s.effop)
	c:RegisterEffect(e3)

end

s.counter_place_list={0x118a}
s.listed_series={0x422}
s.listed_names={id,13741143,13741189}
s.material={13741143,13741189}

function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return rp==1-tp and loc&LOCATION_ONFIELD>0
end

function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=not Duel.HasFlagEffect(tp,id)
		and Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local b2=not Duel.HasFlagEffect(tp,id+1)
		and Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSpellTrap),tp,0,LOCATION_ONFIELD,e:GetHandler():GetEquipGroup())
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		e:SetCategory(CATEGORY_DESTROY)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
	elseif op==2 then
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
		e:SetCategory(CATEGORY_DESTROY)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
	end
end

function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--● Destroy all face-up monsters your opponent controls
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	elseif op==2 then
		--● Destroy all face-up Spells/Traps your opponent controls
		local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSpellTrap),tp,0,LOCATION_ONFIELD,nil)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
