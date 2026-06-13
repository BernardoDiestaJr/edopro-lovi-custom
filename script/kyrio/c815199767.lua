--Grand Deluge of the Seven Abyssins
local s,id=GetID()
function s.initial_effect(c)
	--Reveal 3 WATER Ritual Monsters from your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtgtg)
	e1:SetOperation(s.thtgop)
	c:RegisterEffect(e1)
	--Shuffle this card into the Deck, then Set 1 Kyrio Ritual Spell from your Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end

s.listed_series={0x1fd}
s.listed_names={id}

function s.revfilter(c)
	return c:IsRitualMonster() and c:IsAttribute(ATTRIBUTE_WATER) and (c:IsAbleToHand() or c:IsAbleToGrave())
end

function s.thtgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.revfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return #g>=3 and g:IsExists(Card.IsAbleToHand,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)
end

function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsAbleToHand,1,nil)
end

function s.thtgop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.revfilter,tp,LOCATION_DECK,0,nil)
	if #g>=3 and g:IsExists(Card.IsAbleToHand,1,nil) then
		local rg=aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,1,tp,HINTMSG_CONFIRM)
		Duel.ConfirmCards(1-tp,rg)
		Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(id,1))
		local sc=rg:FilterSelect(1-tp,Card.IsAbleToHand,1,1,nil):GetFirst()
		Duel.SendtoHand(sc,nil,REASON_EFFECT)
		Duel.SendtoGrave(rg-sc,REASON_EFFECT)
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	--You cannot Special Summon from the Extra Deck for the rest of this turn after this card resolves
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)	
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_SEASERPENT)
end

function s.tdfilter(c)
	return c:IsSetCard(0x1fd) and c:IsRitualSpell() and c:IsSSetable()
end

function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,tp,0)
end

function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.BreakEffect()
		Duel.SSet(tp,g)
	end
end