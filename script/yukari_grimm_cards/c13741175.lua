--Crawling Chaos Jabberwock
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x118a)
	c:EnableReviveLimit()
	--Synchro Summon procedure
	Synchro.AddProcedure(c,aux.FilterBoolFunction(Card.IsLevel,6),1,1,Synchro.NonTunerEx(Card.IsRace,RACE_WARRIOR),1,99)	
	--Monsters your opponent controls lose 100 ATK/DEF for each Black Soul Counter on the field
	local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_FIELD)
	e0a:SetCode(EFFECT_UPDATE_ATTACK)
	e0a:SetRange(LOCATION_MZONE)
	e0a:SetTargetRange(0,LOCATION_MZONE)
	e0a:SetValue(function(e,c) return Duel.GetCounter(0,1,1,0x118a)*-100 end)
	c:RegisterEffect(e0a)
	local e0b=e0a:Clone()
	e0b:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e0b)	
	--Place Black Soul Counters on this card, equal to the number of monsters in the GYs
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function(e) return e:GetHandler():IsSynchroSummoned() end)
	e1:SetTarget(s.cttg)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	--Target 1 monster your opponent controls; take control of that monster, and if you do, the targeted monster becomes a Zombie monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.tccon)
	e2:SetCost(s.tccost)
	e2:SetTarget(s.tctg)
	e2:SetOperation(s.tcop)
	c:RegisterEffect(e2)
	--If this Synchro Summoned card is sent to the GY: You can banish this card from your GY, then target 1 Level 6 Tuner monster from your GY; add it to your hand or Special Summon it, then immediately after this effect resolves, you can Synchro Summon 1 Synchro Monster
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(function(e) local c=e:GetHandler() return c:IsSynchroSummoned() and c:IsPreviousLocation(LOCATION_MZONE) end)
	e3:SetCost(Cost.SelfBanish)
	e3:SetTarget(s.thsptg)
	e3:SetOperation(s.thspop)
	c:RegisterEffect(e3)	
end

s.counter_place_list={0x118a}
s.listed_series={}
s.listed_names={id}

function s.ctfilter(c)
	return c:IsMonster() and c:IsLocation(LOCATION_GRAVE)
end

function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=Duel.GetMatchingGroupCount(s.ctfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	if ct>0 then
		Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,ct,0,0x118a)
	end
end

function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=Duel.GetMatchingGroupCount(s.ctfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	if c:IsRelateToEffect(e) and ct>0 then
		c:AddCounter(0x118a,ct)
	end
end

function s.tccon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsMonsterEffect() and Chain.IsTriggeringLocation(ev,LOCATION_MZONE)
end

function s.tccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x118a,5,REASON_COST) end
	Duel.RemoveCounter(tp,1,0,0x118a,5,REASON_COST)
end

function s.tctg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:GetControler()~=tp and chkc:IsControlerCanBeChanged() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,Card.IsControlerCanBeChanged,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end

function s.tcop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.GetControl(tc,tp)
		--The targeted monster becomes a Zombie monster
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_COPY_INHERIT)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(RACE_ZOMBIE)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end

function s.thspfilter(c,e,tp,mmz_chk)
	return c:IsType(TYPE_TUNER) and c:IsLevel(6) and c:IsFaceup()
		and (c:IsAbleToHand() or (mmz_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end

function s.thsptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mmz_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thspfilter(chkc,e,tp,mmz_chk) end
	if chk==0 then return Duel.IsExistingTarget(s.thspfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,mmz_chk) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
	local g=Duel.SelectTarget(tp,s.thspfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,mmz_chk)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,0)
	if g:GetFirst():IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,tp,0)
	end
end

function s.thspop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or not aux.ToHandOrElse(tc,tp,
		function() return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false) end,
		function() return Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 end,
		aux.Stringid(id,4)
	) then return end
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		Duel.SynchroSummon(tp,sg:GetFirst())
	end
end