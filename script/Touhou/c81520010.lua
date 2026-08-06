--Windrous Sea Opening "Mosaic Split"
local s,id=GetID()
function s.initial_effect(c)
	--When a Spell/Trap Card, or monster effect, is activated, while you control a WIND Synchro Monster or "Sanae, Windrous Fantasia Priestess": Negate the activation, and if you do, destroy that card
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,1))
	e0:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetCountLimit(1,id)
	e0:SetCondition(s.negcon)
	e0:SetCost(s.negcost)
	e0:SetTarget(s.negtg)
	e0:SetOperation(s.negop)
	c:RegisterEffect(e0)	
	--You can activate this card the turn it was Set, by revealing 1 "Windrous Divitant Yasaka no Mikoto" or 1 "Windrous Divitant Moriya no Okami" in your Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e1:SetValue(function(e) e:SetLabel(1) end)
	e1:SetCondition(function(e) return Duel.IsExistingMatchingCard(s.extracostfilter,e:GetHandlerPlayer(),LOCATION_EXTRA,0,1,nil) end)
	c:RegisterEffect(e1)
	e0:SetLabelObject(e1)
	--Set this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_SET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsMonsterEffect() end)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	
end

s.listed_series={0x2f1}
s.listed_names={id,81519989,81520004,81520005}

function s.extracostfilter(c)
	return (c:IsCode(81520004) or c:IsCode(81520005)) and not c:IsPublic()
end

function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local label_obj=e:GetLabelObject()
	if chk==0 then label_obj:SetLabel(0) return true end
	if label_obj:GetLabel()>0 then
		label_obj:SetLabel(0)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local g=Duel.SelectMatchingCard(tp,s.extracostfilter,tp,LOCATION_EXTRA,0,1,1,nil)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
end

function s.negconfilter(c)
	return c:IsFaceup() and (c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_SYNCHRO) or c:IsCode(81519989))
end

function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.negconfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsChainNegatable(ev) and (re:IsMonsterEffect() or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end

function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end

function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,tp,0)
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsSSetable() and Duel.SSet(tp,c) then
		--Return it to Deck if it leaves the field
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3301)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT|RESETS_REDIRECT)
		e1:SetValue(LOCATION_DECKBOT)
		c:RegisterEffect(e1)		
	end
end