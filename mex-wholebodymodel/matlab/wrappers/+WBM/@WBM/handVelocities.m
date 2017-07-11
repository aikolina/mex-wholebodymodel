function [vc_h, v_prms] = handVelocities(obj, hand_conf, varargin)
    ctc_l = hand_conf.contact.left;
    ctc_r = hand_conf.contact.right;

    % check the contact state (CS) of the hands:
    if (ctc_l && ctc_r)
        % both hands:
        hand_idx_list = horzcat(hand_conf.lnk_idx_l, hand_conf.lnk_idx_r);
    elseif ctc_l
        % only left hand:
        hand_idx_list = hand_conf.lnk_idx_l;
    elseif ctc_r
        % only right hand:
        hand_idx_list = hand_conf.lnk_idx_r;
    else
        % no contacts:
        vc_h = obj.ZERO_CVEC_12;
        if (nargout == 2)
            v_prms = struct(); % empty structure ...
        end
        return
    end

    switch nargin
        case 7
            % normal mode:
            % wf_R_b = varargin{1}
            % wf_p_b = varargin{2}
            % q_j    = varargin{3}
            % v_b    = varargin{5}
            dq_j = varargin{1,4};

            wf_R_b_arr = reshape(varargin{1,1}, 9, 1);
            [Jc_h, djcdq_h] = contactJacobians(obj, wf_R_b_arr, varargin{1,2}, varargin{1,3}, ...
                                               dq_j, varargin{1,5}, hand_idx_list);
        case 3
            % optimized mode:
            dq_j = varargin{1,1};

            [Jc_h, djcdq_h] = contactJacobians(obj, hand_idx_list);
        otherwise
            error('WBM::handVelocities: %s', WBM.wbmErrorMsg.WRONG_ARG);
    end
    % calculate the mixed velocity of the hand(s) at the contact link(s):
    vc_h = Jc_h * dq_j;

    if (nargout == 2)
        % data structure of the calculated velocity parameters ...
        v_prms = struct('Jc_h', Jc_h, 'djcdq_h', djcdq_h);
    end
end