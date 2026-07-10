--Ran of Velvet Boundaries
local s,id=GetID()
function s.initial_effect(c)
	c:EnableUnsummonable()
	c:AddMustBeSpecialSummonedByCardEffect()
	--Add 1 "Yukari of Velvet Boundaries" or 1 Level 8 or lower monster that mentions it from your Deck, GY or banishment, or if you control "Chen of Velvet Boundaries", you can Special Summon it instead
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e0:SetProperty(EFFECT_FLAG_DELAY)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCountLimit(1,{id,0})
	e0:SetTarget(s.thsptg)
	e0:SetOperation(s.thspop)
	c:RegisterEffect(e0)	
	--Negate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,{id,1})
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
end

s.listed_names={id,81519982,81519988}

function s.spconfilter(c)
	return c:IsCode(81519988) and c:IsMonster() and c:IsFaceup()
end

function s.thfilter(c,e,tp,yukari_mzone_chk)
	return (c:IsCode(81519982) or (c:IsLevelBelow(8) and c:ListsCode(81519982) and not c:IsCode(id))) and (c:IsAbleToHand() or (yukari_mzone_chk and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end

function s.thsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local yukari_mzone_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_ONFIELD,0,1,nil)
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp,yukari_mzone_chk)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED)
end

function s.thspop(e,tp,eg,ep,ev,re,r,rp)
	local yukari_mzone_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spconfilter,tp,LOCATION_ONFIELD,0,1,nil)
	local hintmsg=yukari_mzone_chk and aux.Stringid(id,2) or HINTMSG_ATOHAND
	Duel.Hint(HINT_SELECTMSG,tp,hintmsg)
	local sc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp,yukari_mzone_chk):GetFirst()
	if not sc then return end
	local op=1
	if yukari_mzone_chk then
		local b1=sc:IsAbleToHand()
		local b2=sc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		op=Duel.SelectEffect(tp,
			{b1,aux.Stringid(id,3)},
			{b2,aux.Stringid(id,4)})
	end
	if op==1 then
		Duel.SendtoHand(sc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sc)
	elseif op==2 then
		Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
	end
end

function s.disconfilter(c)
	return (c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_BEAST) or c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_ILLUSION)) and c:IsMonster() and c:IsFaceup()
end

function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and Duel.IsExistingMatchingCard(s.disconfilter,tp,LOCATION_MZONE,0,1,nil)
end

function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,re:GetHandler(),1,tp,0)
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if Duel.NegateEffect(ev) and rc:IsRelateToEffect(re) and rc:IsDestructable()
		and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
		Duel.BreakEffect()
		Duel.SendtoDeck(eg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end