--Ursarctic Megapilus
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	Ursarctic.AddSpSummonQuickEffect(c,id)
	--Banish 1 card from your opponent's hand face-down, then Special Summon 1 "Ursarctic" monster from Deck or GY, except itself.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.remsptg)
	e2:SetOperation(s.remspop)
	c:RegisterEffect(e2)	
	--If this card is Tributed: You can add this card to your hand, then take 700 damage
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_RELEASE)
	e3:SetCountLimit(2,{id,2})
	e3:SetTarget(s.ursatg)
	e3:SetOperation(s.ursaop)
	c:RegisterEffect(e3)	
end

s.listed_series={SET_URSARCTIC}
s.listed_names={id}

function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_URSARCTIC) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.remsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end

function s.remspop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil,tp,POS_FACEDOWN)
	if #g==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,2)) then return end
	local rg=g:RandomSelect(tp,1)
	if #rg>0 and Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end		
	end
end

function s.ursatg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,700)
end

function s.ursaop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)==1 and c:IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,c)
		Duel.BreakEffect()
		Duel.Damage(tp,700,REASON_EFFECT)
	end
end