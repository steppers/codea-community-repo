// Logging functions
@global
declare function print(msg: string): void;
@js_import print = console.log @js_end

@global
declare function warning(msg: string): void;
@js_import warning = console.warning @js_end

@global
function error(msg: string): void {
    _error('[ERR] ' + msg);
}

declare function _error(msg: string): void;
@js_import _error = console.error @js_end