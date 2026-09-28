--Crawling Chaos Malevolence
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x118a)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Special Summon 1 Fairy "Malevolent" monster or 1 "Crawling Chaos" Synchro Monster from your GY or banishment, but place it on the bottom of the Deck if it leaves the field
	local e1a=Effect.CreateEffect(c)
	e1a:SetDescription(aux.Stringid(id,0))
	e1a:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1a:SetType(EFFECT_TYPE_IGNITION)
	e1a:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1a:SetRange(LOCATION_SZONE)
	e1a:SetCountLimit(1,{id,0})
	e1a:SetCost(s.spcost)
	e1a:SetTarget(s.sptg)
	e1a:SetOperation(s.spop)
	c:RegisterEffect(e1a)	
	local e1b=e1a:Clone()
	e1b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1b:SetCode(EVENT_CHAINING)
	e1b:SetCondition(s.spcon)
	c:RegisterEffect(e1b)	
	--Replace destruction
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.desreptg)
	e2:SetValue(s.desrepval)
	e2:SetOperation(s.desrepop)
	c:RegisterEffect(e2)	
	--add counter
	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3a:SetCode(EVENT_TO_GRAVE)
	e3a:SetRange(LOCATION_SZONE)
	e3a:SetOperation(s.addc)
	c:RegisterEffect(e3a)	
	local e3b=e3a:Clone()
	e3b:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3b)	
end

s.counter_place_list={0x118a}
s.listed_series={0x41f,0x422}
s.listed_names={id,13741143}

function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x118a,5,REASON_COST) end
	Duel.RemoveCounter(tp,1,0,0x118a,5,REASON_COST)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp,chk)
	local trig_loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return ep==1-tp and re:IsMonsterEffect() and trig_loc&(LOCATION_HAND|LOCATION_MZONE|LOCATION_GRAVE)>0
end

function s.spfilter(c,e,tp)
	return (c:IsSetCard(0x41f) and c:IsType(TYPE_SYNCHRO) or c:IsSetCard(0x422) and c:IsRace(RACE_FAIRY)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,#sg,0,0)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
		--Return it to deck if it leaves the field
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3301)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
		e1:SetValue(LOCATION_DECKBOT)
		tc:RegisterEffect(e1,true)
	end
end

function s.repfilter(c,tp)
	return c:IsControler(tp) and (c:IsSetCard(0x41f) or c:IsSetCard(0x422)) and c:IsFaceup()
		and c:IsReason(REASON_BATTLE|REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end

function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		and Duel.IsCanRemoveCounter(tp,1,0,0x118a,5,REASON_EFFECT) end
	return Duel.SelectEffectYesNo(tp,c,96)
end

function s.desrepval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end

function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RemoveCounter(tp,1,0,0x118a,5,REASON_EFFECT|REASON_REPLACE)
end

function s.filter(c,tp)
	return (c:IsSetCard(0x41f) or c:IsSetCard(0x422)) and c:IsPreviousControler(tp) and c:GetPreviousLocation()==LOCATION_MZONE
end

function s.addc(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.filter,1,nil,tp) then
		e:GetHandler():AddCounter(0x118a,1)
	end
end
