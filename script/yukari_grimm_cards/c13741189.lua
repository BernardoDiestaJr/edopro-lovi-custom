--Malevolent Herald of the Crawling Chaos
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x118a)
	c:EnableReviveLimit()
	--Synchro Summon procedure: 1 Tuner + "Grimm the Tragic Knight"
	Synchro.AddProcedure(c,nil,1,1,aux.FilterBoolFunction(Card.IsCode,13741143),1,1)
	--Original ATK becomes 3000
	local e0a=Effect.CreateEffect(c)
	e0a:SetType(EFFECT_TYPE_SINGLE)
	e0a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0a:SetRange(LOCATION_MZONE)
	e0a:SetCode(EFFECT_SET_BASE_ATTACK)
	e0a:SetCondition(s.atkcon)
	e0a:SetValue(3200)
	c:RegisterEffect(e0a)
	local e0b=e0a:Clone()
	e0b:SetCode(EFFECT_SET_BASE_DEFENSE)
	c:RegisterEffect(e0b)	
	--You can remove 10 Black Soul Counters from your field; draw 1 card, then if you control 2 or more Fairy "Malevolent" monsters with different names, draw 2 additional cards
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function(e) return e:GetHandler():IsSynchroSummoned() end)
	e1:SetCost(s.drcost)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)	
	--Special Summon 1 "Grimm the Tragic Knight" from your hand, Deck, or GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)	
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp) return Duel.IsTurnPlayer(1-tp) end)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Shuffle up to 3 monsters in either GY into the Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,4))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO end)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)	
end

s.counter_place_list={0x118a}
s.listed_series={0x422}
s.listed_names={id,13741143,13741176}
s.material={13741143}

function s.atkcon(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,13741176),0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		or Duel.IsEnvironment(13741176)
end

function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x118a,5,REASON_COST) end
	Duel.RemoveCounter(tp,1,0,0x118a,5,REASON_COST)
end

function s.drfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x422) and c:IsRace(RACE_FAIRY)
end

function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.drfilter,tp,LOCATION_MZONE,0,nil)
	local ct=1
	if g:GetClassCount(Card.GetCode)>=2 then ct=2 end
	if chk==0 then return Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,2)
end

function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.drfilter,tp,LOCATION_MZONE,0,nil)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	if Duel.Draw(p,2,REASON_EFFECT)>0 and g:GetClassCount(Card.GetCode)>=2 then
		Duel.BreakEffect()
		Duel.Draw(p,1,REASON_EFFECT)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,2,2,nil)
		if #sg>0 then
			Duel.BreakEffect()
			Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end


function s.spfilter(c,e,tp)
	return c:IsCode(13741143) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local sg=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil)
		if #sg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local ssg=sg:Select(tp,1,1,nil)
			Duel.SynchroSummon(tp,ssg:GetFirst())
		end		
	end	
end

function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsMonster() and chkc:IsAbleToDeck() end
	if chk==0 then return Duel.IsExistingTarget(aux.AND(Card.IsMonster,Card.IsAbleToDeck),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,aux.AND(Card.IsMonster,Card.IsAbleToDeck),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
end

function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end

