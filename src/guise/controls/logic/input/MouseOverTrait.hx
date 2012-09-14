package guise.controls.logic.input;
import guise.controls.ControlLayers;
import guise.traits.core.IActive;
import composure.traits.AbstractTrait;
import guise.platform.types.InteractionAccessTypes;
import guise.platform.PlatformAccessor;
import msignal.Signal;

/**
 * ...
 * @author Tom Byrne
 */

class MouseOverTrait extends AbstractTrait
{
	@inject
	public var active(default, set_active):IActive;
	public function set_active(value:IActive):IActive {
		this.active = value;
		return value;
	}
	
	public var mouseOver(default, null):Bool;
	private var _mouseOverChanged:Signal1<MouseOverTrait>;
	public var mouseOverChanged(get_mouseOverChanged, null):Signal1<MouseOverTrait>;
	private function get_mouseOverChanged():Signal1<MouseOverTrait> {
		if (_mouseOverChanged == null) {
			_mouseOverChanged = new Signal1();
		}
		return _mouseOverChanged;
	}
	
	private var _mouseOver:Bool;
	private var _mouseInteractions:IMouseInteractions;
	

	public function new(?layerName:String) 
	{
		super();
		
		addSiblingTrait(new PlatformAccessor(IMouseInteractions, layerName, onMouseIntAdd, onMouseIntRemove));
	}
	private function onMouseIntAdd(access:IMouseInteractions):Void {
		_mouseInteractions = access;
		_mouseInteractions.rolledOver.add(onRolledOver);
		_mouseInteractions.rolledOut.add(onRolledOut);
		assessMouseOver();
	}
	private function onMouseIntRemove(access:IMouseInteractions):Void {
		_mouseInteractions.rolledOver.remove(onRolledOver);
		_mouseInteractions.rolledOut.remove(onRolledOut);
		_mouseOver = false;
		_mouseInteractions = null;
	}
	private function onRolledOver(?info:MouseInfo):Void {
		_mouseOver = true;
		assessMouseOver();
	}
	private function onRolledOut(?info:MouseInfo):Void {
		_mouseOver = false;
		assessMouseOver();
	}
	
	private function assessMouseOver():Void {
		var value:Bool = ((active == null || active.active) && _mouseInteractions != null && _mouseOver);
		
		if (this.mouseOver != value) {
			this.mouseOver = value;
			if (_mouseOverChanged != null)_mouseOverChanged.dispatch(this);
		}
	}
}