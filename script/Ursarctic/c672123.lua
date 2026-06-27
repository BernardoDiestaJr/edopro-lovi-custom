--Ursarctic Major Flagship
local s,id=GetID()
function s.initial_effect(c)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	--Must be special summoned by its own method
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	--Special summon procedure (from extra deck)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(s.sprcon)
	e2:SetTarget(s.sprtg)
	e2:SetOperation(s.sprop)
	c:RegisterEffect(e2)
	--If your "Ursarctic" monster would Tribute a monster(s) to activate its effect, you can banish 1 Level 7 or higher "Ursarctic" monster from your GY instead
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_COST_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(1,0)
	e3:SetCondition(s.repcon)
	e3:SetValue(s.repval)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)	
	--Add to your hand 1 "Ursarctic" card from your GY or that is banished
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,4))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCountLimit(1)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_RELEASE)
	c:RegisterEffect(e5)
	--Negate an opponent's activated effect
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))
	e6:SetCategory(CATEGORY_DISABLE+CATEGORY_RELEASE)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_CHAINING)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCountLimit(1)
	e6:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return rp==1-tp and (Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,0,LOCATION_HAND,1,nil,REASON_EFFECT,1-tp) or Duel.IsChainDisablable(ev)) end)
	e6:SetTarget(s.distg)
	e6:SetOperation(s.disop)
	c:RegisterEffect(e6)	
end

s.listed_series={SET_URSARCTIC}
s.listed_names={id}

function s.sprfilter(c)
	return c:IsFaceup() and c:IsAbleToGraveAsCost() and c:HasLevel()
end

function s.sprfilter1(c,tp,g,sc)
	local lv=c:GetLevel()
	local g=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_MZONE,0,nil)
	return c:IsType(TYPE_TUNER) and c:IsLevelAbove(8) and g:IsExists(s.sprfilter2,1,c,tp,c,sc)
end

function s.sprfilter2(c,tp,mc,sc)
	local sg=Group.FromCards(c,mc)
	return math.abs(c:GetLevel()-mc:GetLevel())==7 and c:IsType(TYPE_SYNCHRO) and not c:IsType(TYPE_TUNER) and Duel.GetLocationCountFromEx(tp,tp,sg,sc)>0
end

function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_MZONE,0,nil)
	return g:IsExists(s.sprfilter1,1,nil,tp,g,c)
end

function s.sprtg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_MZONE,0,nil)
	local g1=g:Filter(s.sprfilter1,nil,tp,g,c)
	local mg1=aux.SelectUnselectGroup(g1,e,tp,1,1,nil,1,tp,HINTMSG_TOGRAVE,nil,nil,true)
	if #mg1>0 then
		local mc=mg1:GetFirst()
		local g2=g:Filter(s.sprfilter2,mc,tp,mc,c,mc:GetLevel())
		local mg2=aux.SelectUnselectGroup(g2,e,tp,1,1,nil,1,tp,HINTMSG_TOGRAVE,nil,nil,true)
		mg1:Merge(mg2)
	end
	if #mg1==2 then
		mg1:KeepAlive()
		e:SetLabelObject(mg1)
		return true
	end
	return false
end

function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoGrave(g,REASON_COST)
end

function s.repconfilter(c,extracon,base,e,tp,eg,ep,ev,re,r,rp)
	return c:IsLevelAbove(7) and c:IsSetCard(SET_URSARCTIC) and c:IsAbleToRemoveAsCost()
		and (not extracon or extracon(base,e,tp,eg,ep,ev,re,r,rp,c))
end

function s.repcon(e)
	return Duel.IsExistingMatchingCard(s.repconfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end

function s.repval(base,extracon,e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	return c:IsSetCard(SET_URSARCTIC) and c:IsMonster()
		and Duel.IsExistingMatchingCard(s.repconfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil,extracon,base,e,tp,eg,ep,ev,re,r,rp)
end

function s.repop(base,extracon,e,tp,eg,ep,ev,re,r,rp,chk)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.repconfilter,tp,LOCATION_GRAVE,0,1,1,nil,extracon,base,e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(g,POS_FACEUP,REASON_COST|REASON_REPLACE)
end

function s.thfilter(c)
	return c:IsSetCard(SET_URSARCTIC) and c:IsFaceup() and c:IsAbleToHand() and not c:IsCode(id)
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE|LOCATION_REMOVED) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,tp,REASON_EFFECT)
	end
end

function s.disfilter(c)
	return c:IsMonster() and c:IsLevelBelow(7) and c:IsLocation(LOCATION_HAND) and c:IsDiscardable()
end

function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_HANDES,nil,1,1-tp,1)
end

function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local b1=Duel.IsExistingMatchingCard(s.disfilter,tp,0,LOCATION_HAND,1,nil,REASON_EFFECT,1-tp)
	local b2=Duel.IsChainDisablable(ev)
	local op=nil
	if b1 and b2 then
		op=Duel.SelectEffect(1-tp,
			{b1,aux.Stringid(id,3)},
			{b2,aux.Stringid(id,4)})
	else
		op=(b1 and 1) or (b2 and 2)
	end
	if op==1 then
		Duel.DiscardHand(1-tp,nil,1,1,REASON_EFFECT|REASON_DISCARD)
	elseif op==2 then
		Duel.NegateEffect(ev)
	end
end
