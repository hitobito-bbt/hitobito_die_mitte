# encoding: utf-8

#  Copyright (c) 2012-2020, CVP Schweiz. This file is part of
#  hitobito_cvp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_cvp.

class Group::OrtParteigremium < Group

  class Praesident < Role; end
  class Leitung < Group::Simple::Leitung; end
  class Mitglied < Group::Simple::Mitglied; end
  class Gast < Role; end

  roles Praesident, Leitung, Mitglied, Gast


end
